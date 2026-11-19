import '../common/enums.dart';
import '../common/json_reader.dart';
import 'exercise.dart';

/// Пак упражнений v1 (SCHEMAS §2).
final class ExercisePack {
  const ExercisePack({
    this.schemaVersion = 1,
    required this.pack,
    required this.title,
    required this.defaultLocale,
    required this.license,
    required this.packSource,
    required this.status,
    required this.exercises,
  });

  factory ExercisePack.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    expectKind(o, kind);
    return ExercisePack(
      schemaVersion: o.integer('schemaVersion'),
      pack: o.string('pack'),
      title: o.text('title'),
      defaultLocale: o.string('defaultLocale'),
      license: o.string('license'),
      packSource: o.enumValue('packSource', PackSource.values),
      status: o.enumValue('status', PackStatus.values),
      exercises: o.req(
        'exercises',
        listOf((v, p) => Exercise.read(convObject(v, p))),
      ),
    );
  }

  /// Значение поля `kind`.
  static const kind = 'exercise_pack';

  final int schemaVersion;
  final String pack;
  final String title;
  final String defaultLocale;
  final String license;

  /// Недоверенное поле файла (решение 10).
  final PackSource packSource;
  final PackStatus status;
  final List<Exercise> exercises;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'kind': kind,
    'pack': pack,
    'title': title,
    'defaultLocale': defaultLocale,
    'license': license,
    'packSource': packSource.wire,
    'status': status.wire,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
