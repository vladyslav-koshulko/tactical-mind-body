import '../common/enums.dart';
import '../common/json_reader.dart';
import 'cognitive_task.dart';
import 'task_category.dart';

/// Пак задач v1 (SCHEMAS §1): один язык, много категорий и задач.
final class TaskPack {
  const TaskPack({
    this.schemaVersion = 1,
    required this.pack,
    required this.title,
    required this.locale,
    required this.license,
    required this.packSource,
    required this.status,
    required this.levels,
    required this.categories,
    required this.items,
  });

  factory TaskPack.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    expectKind(o, kind);
    return TaskPack(
      schemaVersion: o.integer('schemaVersion'),
      pack: o.string('pack'),
      title: o.text('title'),
      locale: o.string('locale'),
      license: o.string('license'),
      packSource: o.enumValue('packSource', PackSource.values),
      status: o.enumValue('status', PackStatus.values),
      levels: o.req('levels', listOf(enumOf(DifficultyLevel.values))),
      categories: o.req(
        'categories',
        listOf((v, p) => TaskCategory.read(convObject(v, p))),
      ),
      items: o.req(
        'items',
        listOf((v, p) => CognitiveTask.read(convObject(v, p))),
      ),
    );
  }

  /// Значение поля `kind`.
  static const kind = 'task_pack';

  final int schemaVersion;
  final String pack;
  final String title;
  final String locale;
  final String license;

  /// Недоверенное поле файла (решение 10): итоговое значение присваивает
  /// тот, кто пак установил, а не сам файл.
  final PackSource packSource;
  final PackStatus status;
  final List<DifficultyLevel> levels;
  final List<TaskCategory> categories;
  final List<CognitiveTask> items;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'kind': kind,
    'pack': pack,
    'title': title,
    'locale': locale,
    'license': license,
    'packSource': packSource.wire,
    'status': status.wire,
    'levels': levels.map((e) => e.wire).toList(),
    'categories': categories.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
  };
}
