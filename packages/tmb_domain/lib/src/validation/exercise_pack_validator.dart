import '../exercises/exercise.dart';
import '../exercises/exercise_pack.dart';
import 'checker.dart';
import 'issues.dart';
import 'pack_common.dart';
import 'schema_constants.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_result.dart';

const _rootKeys = {
  'schemaVersion',
  'kind',
  'pack',
  'title',
  'defaultLocale',
  'license',
  'packSource',
  'status',
  'exercises',
};

const _exerciseKeys = {
  'id',
  'name',
  'unit',
  'muscleGroups',
  'inventory',
  'locations',
  'legacyId',
};

/// Проверяет пак упражнений (SCHEMAS §2, §6.1, §6.3).
ValidationResult validateExercisePackDocument(
  Map<String, Object?> root,
  ValidationContext ctx,
  Issues issues,
) {
  final limits = ctx.limits;
  final hdr = Issues();
  final h = Checker(hdr, limits);

  h.unknownFields(root, '', _rootKeys);
  final packSource = validateCommonHeader(root, h, ctx);
  final defaultLocale = h.takePattern(
    root,
    '',
    'defaultLocale',
    localePattern,
    ValidationCode.packBadFormat,
    'Локаль по умолчанию «defaultLocale»',
  );
  final rawExercises = takeElements(h, root, 'exercises', limits.maxExercises);
  issues.addAll(hdr.list);
  var rejected = hdr.hasErrors;

  final accepted = <Exercise>[];
  final acceptedMaps = <Map<String, Object?>>[];
  final excluded = <ExcludedElement>[];

  if (rawExercises != null) {
    final seenIds = <String>{};
    final seenLegacy = <int>{};
    final seenNames = <String>{};
    for (var i = 0; i < rawExercises.length; i++) {
      final at = joinIndex('exercises', i);
      final local = Issues();
      final c = Checker(local, limits);
      final item = c.object(rawExercises[i], at);
      String? id;
      int? legacyId;
      String? nameKey;
      String? shownName;
      if (item != null) {
        c.unknownFields(item, at, _exerciseKeys);
        final idRaw = c.take(item, at, 'id');
        if (idRaw != null) {
          id = c.pattern(
            idRaw,
            joinKey(at, 'id'),
            exerciseIdPattern,
            ValidationCode.packBadId,
            'Идентификатор упражнения',
          );
        }
        if (id != null && seenIds.contains(id)) {
          c.add(
            ValidationCode.packDupId,
            joinKey(at, 'id'),
            'Упражнение с id «$id» уже есть в паке: остаётся первое.',
          );
        }
        final name = _name(item, at, c, defaultLocale);
        shownName = name?.$1;
        nameKey = name?.$2;
        c.takeWire(
          item,
          at,
          'unit',
          unitWires,
          ValidationCode.packBadEnum,
          'Единица «unit»',
        );
        _tags(
          item,
          at,
          c,
          'muscleGroups',
          known: knownMuscleGroups,
          min: 1,
          max: 6,
        );
        _tags(item, at, c, 'inventory', known: knownInventory, min: 0, max: 4);
        _locations(item, at, c);
        legacyId = _legacyId(item, at, c);
        if (legacyId != null && seenLegacy.contains(legacyId)) {
          c.add(
            ValidationCode.exDupLegacyId,
            joinKey(at, 'legacyId'),
            'legacyId $legacyId уже занят другим упражнением.',
          );
        }
      }
      Exercise? model;
      if (item != null && !local.hasErrors) {
        model = buildModel(() => Exercise.fromJson(item), at, local);
      }
      if (model != null && nameKey != null && seenNames.contains(nameKey)) {
        local.add(
          ValidationCode.exDupName,
          joinKey(at, 'name'),
          'Название «$shownName» уже есть у другого упражнения.',
        );
      }
      issues.addAll(local.list);
      if (model != null && !local.hasErrors) {
        seenIds.add(model.id);
        if (model.legacyId != null) seenLegacy.add(model.legacyId!);
        if (nameKey != null) seenNames.add(nameKey);
        accepted.add(model);
        acceptedMaps.add(item!);
      } else {
        excluded.add(
          ExcludedElement(path: at, index: i, id: id, codes: local.errorCodes),
        );
      }
    }
  }

  ExercisePack? pack;
  if (!rejected) {
    final json = {
      ...root,
      'packSource': ?packSource,
      'exercises': acceptedMaps,
    };
    pack = buildModel(() => ExercisePack.fromJson(json), '\$', issues);
    if (pack == null) rejected = true;
  }
  if (rejected) {
    return ValidationResult(
      kind: DocumentKind.exercisePack,
      issues: issues.list,
      isDocumentRejected: true,
    );
  }
  return ValidationResult(
    kind: DocumentKind.exercisePack,
    issues: issues.list,
    isDocumentRejected: false,
    excluded: excluded,
    acceptedExercises: accepted,
    exercisePack: pack,
  );
}

/// `name`: карта локаль → строка (SCHEMAS §2.2). Возвращает название на
/// `defaultLocale` и его нормализованный вид для правила дубликатов.
(String, String)? _name(
  Map<String, Object?> item,
  String at,
  Checker c,
  String? defaultLocale,
) {
  final nameAt = joinKey(at, 'name');
  final raw = c.take(item, at, 'name');
  if (raw == null) return null;
  if (raw is! Map<String, Object?>) {
    c.add(
      ValidationCode.exBadName,
      nameAt,
      '«name» — карта «локаль → название», получено не объект.',
    );
    return null;
  }
  if (raw.isEmpty || raw.length > c.limits.exerciseNameLocales) {
    c.add(
      raw.isEmpty ? ValidationCode.exBadName : ValidationCode.packLimitArray,
      nameAt,
      'В «name» от 1 до ${c.limits.exerciseNameLocales} локалей '
      '(сейчас ${raw.length}).',
    );
    return null;
  }
  String? defaultName;
  for (final entry in raw.entries) {
    final entryAt = joinKey(nameAt, entry.key);
    if (!localePattern.hasMatch(entry.key)) {
      c.add(
        ValidationCode.exBadName,
        entryAt,
        'Ключ «${entry.key}» в «name» не похож на локаль (например, ru или en-US).',
      );
      continue;
    }
    final value = c.text(
      entry.value,
      entryAt,
      max: c.limits.exerciseNameLength,
      emptyCode: ValidationCode.exBadName,
    );
    if (entry.key == defaultLocale) defaultName = value;
  }
  if (defaultLocale != null && !raw.containsKey(defaultLocale)) {
    c.add(
      ValidationCode.exBadName,
      nameAt,
      'В «name» нет названия на языке по умолчанию «$defaultLocale».',
    );
  }
  return defaultName == null
      ? null
      : (defaultName, normalizeForCompare(defaultName));
}

void _tags(
  Map<String, Object?> item,
  String at,
  Checker c,
  String key, {
  required Set<String> known,
  required int min,
  required int max,
}) {
  final tagsAt = joinKey(at, key);
  final raw = c.takeArray(item, at, key);
  if (raw == null) return;
  if (raw.isEmpty && min > 0) {
    c.add(
      ValidationCode.exNoMuscles,
      tagsAt,
      'Нужна хотя бы одна группа мышц.',
    );
    return;
  }
  if (raw.length > max) {
    c.add(
      ValidationCode.packLimitArray,
      tagsAt,
      'В «$key» не больше $max тегов (сейчас ${raw.length}).',
    );
    return;
  }
  final seen = <String>{};
  for (var i = 0; i < raw.length; i++) {
    final tagAt = joinIndex(tagsAt, i);
    final tag = c.pattern(
      raw[i],
      tagAt,
      tagPattern,
      ValidationCode.exBadTag,
      'Тег',
    );
    if (tag == null) continue;
    if (!seen.add(tag)) {
      c.add(ValidationCode.exBadTag, tagAt, 'Тег «$tag» повторяется.');
    } else if (!known.contains(tag)) {
      c.add(
        ValidationCode.exUnknownTag,
        tagAt,
        'Неизвестный тег «$tag»: он сохранится, но не участвует в фильтрах.',
      );
    }
  }
}

void _locations(Map<String, Object?> item, String at, Checker c) {
  final locAt = joinKey(at, 'locations');
  final raw = c.takeArray(item, at, 'locations');
  if (raw == null) return;
  if (raw.isEmpty || raw.length > 3) {
    c.add(
      ValidationCode.exBadLocation,
      locAt,
      'В «locations» от 1 до 3 мест (сейчас ${raw.length}).',
    );
    return;
  }
  final seen = <String>{};
  for (var i = 0; i < raw.length; i++) {
    final v = c.wire(
      raw[i],
      joinIndex(locAt, i),
      locationWires,
      ValidationCode.exBadLocation,
      'Место',
    );
    if (v != null && !seen.add(v)) {
      c.add(
        ValidationCode.exBadLocation,
        joinIndex(locAt, i),
        'Место «$v» повторяется.',
      );
    }
  }
}

int? _legacyId(Map<String, Object?> item, String at, Checker c) {
  final legacyAt = joinKey(at, 'legacyId');
  if (!item.containsKey('legacyId')) {
    c.add(
      ValidationCode.packMissingField,
      legacyAt,
      'Обязательное поле «legacyId» отсутствует (у нового упражнения — null).',
    );
    return null;
  }
  final v = item['legacyId'];
  if (v == null) return null;
  if (v is int && v >= 1) return v;
  c.add(
    ValidationCode.exBadLegacyId,
    legacyAt,
    '«legacyId» — целое число от 1 или null.',
  );
  return null;
}
