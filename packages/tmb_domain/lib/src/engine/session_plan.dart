import '../common/enums.dart';
import '../content/cognitive_task.dart';
import '../content/task_archetype.dart';
import '../exercises/exercise.dart';
import '../session/session_template.dart';
import 'task_source.dart';

/// Конкретный план сессии: что именно, в каком порядке и в каком объёме
/// увидит пользователь. Строится [SessionPlanner] целиком при старте и
/// дальше не меняется (D6: план не подстраивается внутри сессии).
///
/// План — чистые данные плюс ссылки на провайдеров (они нужны движку для
/// `verify`). Одинаковые входы и сид → план с одинаковым [toJson]
/// (инвариант 4).
final class SessionPlan {
  SessionPlan({
    required this.seed,
    required this.template,
    required this.location,
    required this.difficulty,
    required List<PlannedBlock> blocks,
  }) : blocks = List.unmodifiable(blocks);

  /// Главный сид сессии; из него выводятся сиды блоков и задач.
  final int seed;
  final SessionTemplate template;
  final Location location;
  final DifficultyLevel difficulty;

  /// По одному элементу на каждый блок шаблона, в том же порядке.
  final List<PlannedBlock> blocks;

  /// Каноничное представление для сравнения и отладки: содержит всё, что
  /// влияет на показанное пользователю.
  Map<String, Object?> toJson() => {
    'seed': seed,
    'template': template.toJson(),
    'location': location.wire,
    'difficulty': difficulty.wire,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };
}

/// Блок плана; соответствует блоку шаблона с тем же [blockIndex].
sealed class PlannedBlock {
  const PlannedBlock({required this.blockIndex});

  /// Позиция в списке блоков сессии.
  final int blockIndex;

  Map<String, Object?> toJson();
}

/// Физический круг: упражнения и их цели, зафиксированные при старте.
final class PlannedPhysicalBlock extends PlannedBlock {
  PlannedPhysicalBlock({
    required super.blockIndex,
    required this.roundIndex,
    required List<PlannedExercise> exercises,
  }) : exercises = List.unmodifiable(exercises);

  /// `RoundLog.roundIndex`: сколько физических блоков стоит раньше.
  final int roundIndex;
  final List<PlannedExercise> exercises;

  @override
  Map<String, Object?> toJson() => {
    'type': 'physical',
    'blockIndex': blockIndex,
    'roundIndex': roundIndex,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

/// Упражнение круга с целью (`ExerciseSet.prescribed`).
final class PlannedExercise {
  const PlannedExercise({required this.exercise, required this.prescribed});

  final Exercise exercise;

  /// Повторения или секунды — по [unit].
  final int prescribed;

  String get exerciseId => exercise.id;
  ExerciseUnit get unit => exercise.unit;

  Map<String, Object?> toJson() => {
    'exerciseId': exerciseId,
    'unit': unit.wire,
    'prescribed': prescribed,
  };
}

/// Когнитивное окно: упорядоченные задачи и жёсткий срок [durationSec].
final class PlannedCognitiveBlock extends PlannedBlock {
  PlannedCognitiveBlock({
    required super.blockIndex,
    required this.roundIndex,
    required this.durationSec,
    required List<PlannedTask> tasks,
  }) : tasks = List.unmodifiable(tasks);

  /// `TaskAttempt.roundIndex`: сколько когнитивных блоков начато раньше.
  final int roundIndex;
  final int durationSec;

  /// Сначала отложенные вопросы `delayed_recall` из прошлых окон, затем
  /// новые задачи.
  final List<PlannedTask> tasks;

  @override
  Map<String, Object?> toJson() => {
    'type': 'cognitive',
    'blockIndex': blockIndex,
    'roundIndex': roundIndex,
    'durationSec': durationSec,
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };
}

/// Пассивный отдых.
final class PlannedRestBlock extends PlannedBlock {
  const PlannedRestBlock({
    required super.blockIndex,
    required this.durationSec,
  });

  final int durationSec;

  @override
  Map<String, Object?> toJson() => {
    'type': 'rest',
    'blockIndex': blockIndex,
    'durationSec': durationSec,
  };
}

/// Роль слота задачи в окне.
enum PlannedTaskRole {
  /// Обычная задача: показ (если есть) и ответ в одном слоте. `delayed_recall`
  /// в этой роли — «вырожденный» случай: позже вопроса задать негде (сессия
  /// кончается раньше), поэтому запоминание и вопрос идут подряд.
  standard,

  /// Только фаза запоминания `delayed_recall`; `TaskAttempt` не пишется
  /// (запись создаётся один раз, при ответе — SCHEMAS §1.4).
  memorize,

  /// Вопрос `delayed_recall`, заданный спустя `delayRounds` окон; пишет
  /// `TaskAttempt` с `encodedRoundIndex`.
  recallQuestion,
}

/// Одна задача в когнитивном окне.
final class PlannedTask {
  PlannedTask({
    required this.task,
    required this.seed,
    required this.source,
    required this.payloadHash,
    this.role = PlannedTaskRole.standard,
    this.encodedRoundIndex,
    List<int> cueMomentsSec = const [],
  }) : cueMomentsSec = List.unmodifiable(cueMomentsSec);

  final CognitiveTask task;

  /// Сид, с которым вызван `provider.generate` (пишется в `TaskAttempt.seed`):
  /// пара `(seed, payloadHash)` восстанавливает показанное (SCHEMAS §3.5).
  final int seed;
  final TaskSource source;
  final String payloadHash;
  final PlannedTaskRole role;

  /// Только `delayed_recall`: `roundIndex` окна, где было запоминание.
  final int? encodedRoundIndex;

  /// Моменты показа `cues`, секунды от начала фазы ответа (инвариант 4:
  /// считаются от сида, а не от случайности в UI). Пусто, если cues нет.
  final List<int> cueMomentsSec;

  String get providerId => source.provider.id;
  PackSource get packSource => source.packSource;

  /// Есть ли фаза показа перед ответом (запоминание / показ сетки).
  bool get hasStudy => switch (role) {
    PlannedTaskRole.memorize => true,
    PlannedTaskRole.recallQuestion => false,
    PlannedTaskRole.standard =>
      task is SpatialTask || task is DelayedRecallTask,
  };

  /// Есть ли фаза ответа (и значит — `TaskAttempt`).
  bool get hasAnswer => role != PlannedTaskRole.memorize;

  /// Длительность фазы показа в секундах (0, если её нет).
  int get studySec => switch (task) {
    SpatialTask t => t.effectiveShowSec,
    DelayedRecallTask t => t.effectiveShowSec,
    _ => 0,
  };

  TaskArchetype get archetype => task.archetype;

  Map<String, Object?> toJson() => {
    'taskId': task.id,
    'packId': providerId,
    'packSource': packSource.wire,
    'archetype': archetype.wire,
    'seed': seed,
    'payloadHash': payloadHash,
    'role': role.name,
    'encodedRoundIndex': encodedRoundIndex,
    'cueMomentsSec': cueMomentsSec,
  };
}
