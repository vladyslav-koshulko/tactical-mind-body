import 'package:tmb_domain/tmb_domain.dart';

/// Раздел верхнего уровня экрана «Категории» (D2): производное от того,
/// проверяется ли задача машиной.
enum CategorySection { verifiable, unverifiable }

/// Раздел задачи. Для `verbal` — всегда «непроверяемые», даже если пак в
/// обход валидатора пометил `verifiable: true` (инвариант 7: решает архетип).
CategorySection sectionOf(CognitiveTask task) =>
    task.verifiable && task.archetype.isMachineVerifiable
    ? CategorySection.verifiable
    : CategorySection.unverifiable;

/// Состояние галочки узла дерева.
enum CategoryState { on, off, mixed }

/// Узел иерархии категорий: сегмент пути `domain` (`cog` → `memory` → `digits`).
///
/// Узел может быть и группой (только потомки), и категорией со своими
/// задачами (`ownCount > 0`), и тем и другим сразу.
final class CategoryNode {
  CategoryNode({required this.path, required this.segment});

  /// Полный путь узла: `cog.memory`.
  final String path;

  /// Последний сегмент пути: `memory`.
  final String segment;

  /// `categories[].title` пака; `null` у чистых групп и у задач без записи
  /// в `categories`.
  String? title;

  /// Задач с `domain == path` в этом разделе.
  int ownCount = 0;

  final List<CategoryNode> children = [];

  bool get hasOwnTasks => ownCount > 0;

  /// Задач в узле и всех его потомках.
  int get totalCount =>
      ownCount + children.fold<int>(0, (n, c) => n + c.totalCount);

  /// Пути категорий с задачами в узле и под ним: именно их включает и
  /// выключает галочка узла.
  List<String> get domains => [
    if (hasOwnTasks) path,
    for (final c in children) ...c.domains,
  ];
}

/// Каталог категорий установленных паков: два раздела, деревья, число задач.
///
/// Берутся только задачи, которые движок v0.1 способен провести: `stream`
/// исключён так же, как в `SessionPlanner.excludedArchetypes` — иначе
/// пользователь мог бы оставить включённой категорию, из которой план не
/// соберётся.
final class CategoryCatalog {
  CategoryCatalog._(this._roots, this.allDomains);

  factory CategoryCatalog.build(Iterable<TaskPack> packs) {
    final titles = <String, String>{};
    final order = <String>[];
    final counts = <CategorySection, Map<String, int>>{
      for (final s in CategorySection.values) s: {},
    };

    for (final pack in packs) {
      for (final category in pack.categories) {
        titles.putIfAbsent(category.domain, () => category.title);
        if (!order.contains(category.domain)) order.add(category.domain);
      }
      for (final task in pack.items) {
        if (task.archetype == TaskArchetype.stream) continue;
        if (!order.contains(task.domain)) order.add(task.domain);
        final bySection = counts[sectionOf(task)]!;
        bySection[task.domain] = (bySection[task.domain] ?? 0) + 1;
      }
    }

    final roots = <CategorySection, List<CategoryNode>>{};
    for (final section in CategorySection.values) {
      final byPath = <String, CategoryNode>{};
      final top = <CategoryNode>[];
      for (final domain in order) {
        final count = counts[section]![domain];
        if (count == null) continue;
        final segments = domain.split('.');
        CategoryNode? parent;
        for (var i = 0; i < segments.length; i++) {
          final path = segments.take(i + 1).join('.');
          var node = byPath[path];
          if (node == null) {
            node = CategoryNode(path: path, segment: segments[i]);
            byPath[path] = node;
            (parent?.children ?? top).add(node);
          }
          parent = node;
        }
        parent!
          ..title = titles[domain]
          ..ownCount = count;
      }
      roots[section] = List.unmodifiable(top);
    }

    return CategoryCatalog._(roots, {
      for (final s in CategorySection.values) ...counts[s]!.keys,
    });
  }

  final Map<CategorySection, List<CategoryNode>> _roots;

  /// `domain` всех задач, которые попадают в пул, — это и есть
  /// `installedTaskDomains` для проверки «пул не бывает пустым».
  final Set<String> allDomains;

  List<CategoryNode> rootsOf(CategorySection section) => _roots[section]!;

  /// Пути категорий раздела (только с задачами).
  List<String> domainsOf(CategorySection section) => [
    for (final r in rootsOf(section)) ...r.domains,
  ];

  int taskCountOf(CategorySection section) =>
      rootsOf(section).fold<int>(0, (n, r) => n + r.totalCount);

  /// Сколько категорий включено (`enabled`) из общего числа (`total`).
  ({int enabled, int total}) summary(
    Iterable<String> domains,
    Iterable<String> disabled,
  ) {
    final list = domains.toList();
    return (
      enabled: list.where((d) => isCategoryEnabled(d, disabled)).length,
      total: list.length,
    );
  }
}

/// Состояние галочки по путям категорий под узлом.
CategoryState stateOf(Iterable<String> domains, Iterable<String> disabled) {
  var on = 0;
  var off = 0;
  for (final d in domains) {
    if (isCategoryEnabled(d, disabled)) {
      on++;
    } else {
      off++;
    }
  }
  if (off == 0) return CategoryState.on;
  if (on == 0) return CategoryState.off;
  return CategoryState.mixed;
}

/// Новое множество ОТКЛЮЧЁННЫХ путей после включения/выключения [targets].
///
/// Все известные категории ([known]) записываются явными путями: так включить
/// одну категорию под отключённым родителем можно, не теряя остальные.
/// Путь из [disabled], который не покрывает ни одной известной категории
/// (пак не установлен), остаётся нетронутым. Результат отсортирован.
List<String> disabledAfter({
  required Iterable<String> disabled,
  required Set<String> known,
  required Iterable<String> targets,
  required bool enable,
}) {
  final enabled = {
    for (final d in known)
      if (isCategoryEnabled(d, disabled)) d,
  };
  final touched = targets.toSet();
  if (enable) {
    enabled.addAll(touched);
  } else {
    enabled.removeAll(touched);
  }
  final next = <String>{
    for (final d in known)
      if (!enabled.contains(d)) d,
    for (final p in disabled)
      if (!known.any((d) => d == p || d.startsWith('$p.'))) p,
  };
  return next.toList()..sort();
}
