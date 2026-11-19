import '../content/cognitive_task.dart';
import '../content/task_category.dart';
import '../content/task_pack.dart';
import '../determinism/payload_hash.dart';
import 'checker.dart';
import 'issues.dart';
import 'pack_common.dart';
import 'schema_constants.dart';
import 'task_rules.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_result.dart';

const _rootKeys = {
  'schemaVersion',
  'kind',
  'pack',
  'title',
  'locale',
  'license',
  'packSource',
  'status',
  'levels',
  'categories',
  'items',
};

/// Проверяет пак задач (SCHEMAS §1, §6.1–6.2). `root` — разобранный JSON,
/// `schemaVersion` и `kind` уже проверены вызывающим.
ValidationResult validateTaskPackDocument(
  Map<String, Object?> root,
  ValidationContext ctx,
  Issues issues,
) {
  final limits = ctx.limits;
  final hdr = Issues();
  final h = Checker(hdr, limits);

  h.unknownFields(root, '', _rootKeys);
  final packSource = validateCommonHeader(root, h, ctx);

  final locale = h.takePattern(
    root,
    '',
    'locale',
    localePattern,
    ValidationCode.packBadFormat,
    'Локаль',
  );
  final dirLocale = ctx.directoryLocale;
  if (locale != null && dirLocale != null && locale != dirLocale) {
    h.add(
      ValidationCode.packLocaleMismatch,
      'locale',
      'Локаль пака «$locale» не совпадает с каталогом «$dirLocale».',
    );
  }

  // levels: 1…4 уникальных значений из закрытого списка.
  final levels = h.takeArray(root, '', 'levels');
  if (levels != null) {
    if (levels.isEmpty || levels.length > 4) {
      h.add(
        ValidationCode.packLimitArray,
        'levels',
        'В «levels» от 1 до 4 уровней (сейчас ${levels.length}).',
      );
    } else {
      final seen = <String>{};
      for (var i = 0; i < levels.length; i++) {
        final at = joinIndex('levels', i);
        final level = h.wire(
          levels[i],
          at,
          levelWires,
          ValidationCode.packBadEnum,
          'Уровень',
        );
        if (level != null && !seen.add(level)) {
          h.add(
            ValidationCode.packBadEnum,
            at,
            'Уровень «$level» повторяется.',
          );
        }
      }
    }
  }

  final rawCategories = takeElements(
    h,
    root,
    'categories',
    limits.maxCategories,
  );
  final rawItems = takeElements(h, root, 'items', limits.maxTasks);
  issues.addAll(hdr.list);
  var rejected = hdr.hasErrors;

  final categories = <TaskCategory>[];
  final categoryIndex = <String, int>{};
  final categoryMaps = <Map<String, Object?>>[];
  final tasks = <CognitiveTask>[];
  final taskMaps = <Map<String, Object?>>[];
  final hashes = <String, String>{};
  final usedDomains = <String>{};
  final excluded = <ExcludedElement>[];

  // --- категории ---
  if (rawCategories != null) {
    for (var i = 0; i < rawCategories.length; i++) {
      final at = joinIndex('categories', i);
      final local = Issues();
      final c = Checker(local, limits);
      final cat = c.object(rawCategories[i], at);
      String? domain;
      if (cat != null) {
        c.unknownFields(cat, at, const {'domain', 'title', 'description'});
        final raw = c.take(cat, at, 'domain');
        if (raw != null) {
          domain = c.pattern(
            raw,
            joinKey(at, 'domain'),
            domainPattern,
            ValidationCode.packBadDomain,
            'Домен категории',
          );
        }
        c.takeText(cat, at, 'title', max: limits.categoryTitleLength);
        c.takeText(
          cat,
          at,
          'description',
          max: limits.descriptionLength,
          required: false,
        );
        if (domain != null && categoryIndex.containsKey(domain)) {
          c.add(
            ValidationCode.packDupCategory,
            joinKey(at, 'domain'),
            'Категория «$domain» уже объявлена выше.',
          );
        }
      }
      TaskCategory? model;
      if (cat != null && !local.hasErrors) {
        model = buildModel(() => TaskCategory.fromJson(cat), at, local);
      }
      issues.addAll(local.list);
      if (model != null && !local.hasErrors) {
        categoryIndex[model.domain] = i;
        categories.add(model);
        categoryMaps.add(cat!);
      } else {
        excluded.add(
          ExcludedElement(
            path: at,
            index: i,
            id: domain,
            codes: local.errorCodes,
          ),
        );
      }
    }
  }

  // --- задачи ---
  if (rawItems != null) {
    final seenIds = <String>{};
    final seenPrompts = <String>{};
    for (var i = 0; i < rawItems.length; i++) {
      final at = joinIndex('items', i);
      final local = Issues();
      final c = Checker(local, limits);
      final item = c.object(rawItems[i], at);
      TaskFacts? facts;
      if (item != null) {
        facts = validateTask(item, at, c);
        final domain = facts.domain;
        if (domain != null) usedDomains.add(domain);
        if (domain != null && !categoryIndex.containsKey(domain)) {
          c.add(
            ValidationCode.packUndeclaredDomain,
            joinKey(at, 'domain'),
            'Домен «$domain» не объявлен ни в одной категории пака.',
          );
        }
        final id = facts.id;
        if (id != null && seenIds.contains(id)) {
          c.add(
            ValidationCode.packDupId,
            joinKey(at, 'id'),
            'Задача с id «$id» уже есть в паке: остаётся первая.',
          );
        }
        final key = facts.promptKey;
        if (key != null && seenPrompts.contains(key)) {
          c.add(
            ValidationCode.packDupPrompt,
            joinKey(at, 'prompt'),
            'Такой текст задачи уже есть в паке (после нормализации).',
          );
        }
      }
      CognitiveTask? model;
      if (item != null && !local.hasErrors) {
        model = buildModel(() => CognitiveTask.fromJson(item), at, local);
      }
      if (model != null && !local.hasErrors) {
        try {
          hashes[model.id] = payloadHash(model);
        } on UnsupportedError catch (e) {
          local.add(
            ValidationCode.packBadChars,
            at,
            'Не удалось вычислить хеш задачи: ${e.message}',
          );
        }
      }
      issues.addAll(local.list);
      if (model != null && !local.hasErrors) {
        seenIds.add(model.id);
        seenPrompts.add(facts!.promptKey!);
        tasks.add(model);
        taskMaps.add(item!);
      } else {
        excluded.add(
          ExcludedElement(
            path: at,
            index: i,
            id: facts?.id,
            codes: local.errorCodes,
          ),
        );
      }
    }
  }

  // --- пустые категории ---
  for (final entry in categoryIndex.entries) {
    if (!usedDomains.contains(entry.key)) {
      issues.add(
        ValidationCode.packEmptyCategory,
        joinIndex('categories', entry.value),
        'В категории «${entry.key}» нет ни одной задачи.',
      );
    }
  }

  TaskPack? pack;
  if (!rejected) {
    final json = {
      ...root,
      'packSource': ?packSource,
      'categories': categoryMaps,
      'items': taskMaps,
    };
    pack = buildModel(() => TaskPack.fromJson(json), '\$', issues);
    if (pack == null) rejected = true;
  }
  if (rejected) {
    return ValidationResult(
      kind: DocumentKind.taskPack,
      issues: issues.list,
      isDocumentRejected: true,
    );
  }
  return ValidationResult(
    kind: DocumentKind.taskPack,
    issues: issues.list,
    isDocumentRejected: false,
    excluded: excluded,
    acceptedTasks: tasks,
    acceptedCategories: categories,
    payloadHashes: hashes,
    taskPack: pack,
  );
}
