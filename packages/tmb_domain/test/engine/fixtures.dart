import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

/// Опорный момент: 2026-09-18, ровно в мс.
const int t0 = 1795100000000;

TaskPack demoPack() => TaskPack.fromJson(
  jsonDecode(File('test/demo.pack.json').readAsStringSync())
      as Map<String, Object?>,
);

/// Пак из выбранных задач демо-пака (остальное — как в демо).
TaskPack packOf(Iterable<String> ids, {PackSource? source}) {
  final demo = demoPack();
  final items = [
    for (final id in ids) demo.items.firstWhere((t) => t.id == id),
  ];
  return TaskPack(
    pack: demo.pack,
    title: demo.title,
    locale: demo.locale,
    license: demo.license,
    packSource: source ?? demo.packSource,
    status: demo.status,
    levels: demo.levels,
    categories: demo.categories,
    items: items,
  );
}

TaskSource sourceOf(TaskPack pack) => TaskSource.pack(PackTaskProvider(pack));

Exercise exercise(
  String id, {
  ExerciseUnit unit = ExerciseUnit.reps,
  List<Location> locations = const [Location.home],
  List<String> inventory = const [],
}) => Exercise(
  id: id,
  name: {'ru': id},
  unit: unit,
  muscleGroups: const ['core'],
  inventory: inventory,
  locations: locations,
);

/// Шесть упражнений на повторения.
List<Exercise> repsExercises() => [
  for (final n in ['pushup', 'situp', 'squat', 'burpee', 'lunge', 'crunch'])
    exercise('ex.$n'),
];

SessionPlanner plannerWith({
  List<Exercise>? exercises,
  List<TaskSource>? sources,
  ProfileSettings profile = const ProfileSettings(),
  int exercisesPerRound = 3,
  int tasksPerCognitiveBlock = 1,
  Iterable<TaskArchetype> excluded = const [TaskArchetype.stream],
}) => SessionPlanner(
  exercises: exercises ?? repsExercises(),
  sources: sources ?? [sourceOf(demoPack())],
  profile: profile,
  exercisesPerRound: exercisesPerRound,
  tasksPerCognitiveBlock: tasksPerCognitiveBlock,
  excludedArchetypes: excluded,
);

SessionPlan planOf(
  SessionPlanner planner,
  SessionTemplate template, {
  int seed = 42,
  DifficultyLevel difficulty = DifficultyLevel.recruit,
}) => planner.plan(
  template: template,
  seed: seed,
  location: Location.home,
  difficulty: difficulty,
);

SessionEngine engineOf(SessionPlan plan, {int idSeed = 7}) =>
    SessionEngine(plan: plan, ids: SeededIdSource(idSeed));

/// Сериализует события существующим экспортом и проверяет существующим
/// валидатором: ни ошибок, ни предупреждений, ни исключённых записей.
void expectValidEvents(EventsExport export) {
  final bytes = Uint8List.fromList(utf8.encode(jsonEncode(export.toJson())));
  final result = validate(
    bytes,
    const ValidationContext(expectedKind: DocumentKind.eventsExport),
  );
  expect(
    result.issues.map((i) => '${i.code.code} ${i.path}'),
    isEmpty,
    reason: 'валидатор событий',
  );
  expect(result.excluded, isEmpty);
  expect(result.isDocumentRejected, isFalse);
  // Туда-обратно через существующий парсер.
  final back = EventsExport.fromJson(
    jsonDecode(utf8.decode(bytes)) as Map<String, Object?>,
  );
  expect(jsonEncode(back.toJson()), jsonEncode(export.toJson()));
}
