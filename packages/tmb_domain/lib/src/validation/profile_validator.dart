import '../profile/category_filter.dart';
import '../profile/profile_settings.dart';
import 'checker.dart';
import 'issues.dart';
import 'pack_common.dart';
import 'schema_constants.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_result.dart';

const _rootKeys = {
  'schemaVersion',
  'disabledCategories',
  'defaultTargets',
  'exerciseTargets',
  'progression',
};

/// Путь категории в `disabledCategories`: 1…5 сегментов. Это не `domain`
/// (у того минимум 2): отключить можно и корневой раздел, как `it` в примере
/// SCHEMAS §4.
final _categoryPathPattern = RegExp(
  r'^[a-z][a-z0-9_]{0,31}(\.[a-z][a-z0-9_]{0,31}){0,4}$',
);

/// Проверяет фрагмент профиля (SCHEMAS §4, §6.4). Любая ошибка отвергает
/// профиль целиком.
ValidationResult validateProfileDocument(
  Map<String, Object?> root,
  ValidationContext ctx,
  Issues issues,
) {
  final c = Checker(issues, ctx.limits);
  c.unknownFields(root, '', _rootKeys);

  final disabled = _disabledCategories(root, c);

  final targets = c.takeObject(root, '', 'defaultTargets');
  if (targets != null) {
    c.unknownFields(targets, 'defaultTargets', const {'reps', 'seconds'});
    for (final key in const ['reps', 'seconds']) {
      final range = c.takeObject(targets, 'defaultTargets', key);
      if (range != null) {
        _range(range, joinKey('defaultTargets', key), c, withId: false);
      }
    }
  }

  final rawTargets = c.takeArray(root, '', 'exerciseTargets');
  if (rawTargets != null) {
    if (rawTargets.length > 500) {
      c.add(
        ValidationCode.packLimitArray,
        'exerciseTargets',
        'В «exerciseTargets» не больше 500 целей (сейчас ${rawTargets.length}).',
      );
    } else {
      final seen = <String>{};
      for (var i = 0; i < rawTargets.length; i++) {
        final at = joinIndex('exerciseTargets', i);
        final target = c.object(rawTargets[i], at);
        if (target == null) continue;
        final id = _range(target, at, c, withId: true);
        if (id == null) continue;
        if (!seen.add(id)) {
          c.add(
            ValidationCode.profTargetRange,
            joinKey(at, 'exerciseId'),
            'Цель для «$id» задана дважды.',
          );
        }
        final known = ctx.knownExerciseIds;
        if (known != null && !known.contains(id)) {
          c.add(
            ValidationCode.profUnknownExercise,
            joinKey(at, 'exerciseId'),
            'Упражнения «$id» нет в установленных паках.',
          );
        }
      }
    }
  }

  final progression = c.takeObject(root, '', 'progression');
  if (progression != null) {
    c.unknownFields(progression, 'progression', const {'enabled'});
    c.takeBool(progression, 'progression', 'enabled');
  }

  // «Пул не бывает пустым» — правило записи; применяется, если известны
  // домены установленных задач.
  final domains = ctx.installedTaskDomains;
  if (disabled != null &&
      !issues.hasErrors &&
      domains != null &&
      domains.isNotEmpty) {
    if (domains.every((d) => !isCategoryEnabled(d, disabled))) {
      c.add(
        ValidationCode.profEmptyPool,
        'disabledCategories',
        'После этого изменения не останется ни одной задачи: пул не может быть пустым.',
      );
    }
  }

  ProfileSettings? profile;
  if (!issues.hasErrors) {
    profile = buildModel(() => ProfileSettings.fromJson(root), '\$', issues);
  }
  return ValidationResult(
    kind: DocumentKind.profile,
    issues: issues.list,
    isDocumentRejected: issues.hasErrors,
    profile: issues.hasErrors ? null : profile,
  );
}

List<String>? _disabledCategories(Map<String, Object?> root, Checker c) {
  final raw = c.takeArray(root, '', 'disabledCategories');
  if (raw == null) return null;
  if (raw.length > 500) {
    c.add(
      ValidationCode.packLimitArray,
      'disabledCategories',
      'В «disabledCategories» не больше 500 путей (сейчас ${raw.length}).',
    );
    return null;
  }
  final out = <String>[];
  final seen = <String>{};
  for (var i = 0; i < raw.length; i++) {
    final at = joinIndex('disabledCategories', i);
    final path = c.pattern(
      raw[i],
      at,
      _categoryPathPattern,
      ValidationCode.profBadCategory,
      'Путь категории',
    );
    if (path == null) continue;
    if (!seen.add(path)) {
      c.add(ValidationCode.profBadCategory, at, 'Путь «$path» повторяется.');
      continue;
    }
    out.add(path);
  }
  return out;
}

/// `Range` (`{min, max}`) или `ExerciseTarget` (с `exerciseId`, `lockedByUser`).
/// Возвращает `exerciseId` цели.
String? _range(
  Map<String, Object?> m,
  String at,
  Checker c, {
  required bool withId,
}) {
  String? id;
  if (withId) {
    c.unknownFields(m, at, const {'exerciseId', 'min', 'max', 'lockedByUser'});
    id = c.takePattern(
      m,
      at,
      'exerciseId',
      exerciseIdPattern,
      ValidationCode.packBadId,
      'Идентификатор упражнения',
    );
    c.takeBool(m, at, 'lockedByUser');
  } else {
    c.unknownFields(m, at, const {'min', 'max'});
  }
  final lo = _bound(m, at, c, 'min');
  final hi = _bound(m, at, c, 'max');
  if (lo != null && hi != null && lo > hi) {
    c.add(
      ValidationCode.profTargetRange,
      at,
      'Граница «min» ($lo) больше «max» ($hi).',
    );
  }
  return id;
}

int? _bound(Map<String, Object?> m, String at, Checker c, String key) {
  final v = c.take(m, at, key);
  if (v == null) return null;
  return c.intIn(
    v,
    joinKey(at, key),
    min: 1,
    max: 3600,
    code: ValidationCode.profTargetRange,
    what: 'Цель «$key»',
  );
}
