import '../content/cognitive_task.dart';
import '../events/task_attempt.dart';
import 'session_plan.dart';

/// Жизненный цикл движка.
enum EngineStatus {
  /// Создан, `start` не вызывался.
  idle,

  /// Идёт сессия.
  running,

  /// Все блоки пройдены; `Session.endedAt` записан.
  finished,

  /// Прервана `abort`; `Session.endedAt == null` (SCHEMAS §3.1).
  aborted,
}

/// Фаза сессии: аналог `TmbPhase` из UI, но в домене (без Flutter).
///
/// Фаза обязана дублироваться нецветовым каналом (инвариант 6) — это забота
/// UI; движок даёт только саму фазу.
enum Phase { physical, cognitive, rest }

/// Стадия когнитивной задачи.
enum TaskStage {
  /// Показ: запоминание (`delayed_recall`) или сетка (`spatial`).
  study,

  /// Ответ (для `verbal` — речь).
  answer,

  /// Только `verbal`: время речи вышло, ждём самооценку.
  selfCheck,
}

/// Оценка круга одним нажатием → `RoundLog.rpe`.
enum RoundRating {
  easy(1),
  normal(2),
  heavy(3);

  const RoundRating(this.rpe);

  /// 1 = легко, 2 = нормально, 3 = тяжело (SCHEMAS §3.2).
  final int rpe;
}

/// Подсказка `cues`, которая к моменту снимка уже должна быть показана.
final class DueCue {
  const DueCue({required this.index, required this.atSec, required this.text});

  /// Позиция в `VerbalTask.cues`.
  final int index;

  /// Момент показа, секунды от начала фазы ответа.
  final int atSec;
  final String text;
}

/// Итог последней завершённой попытки (для экрана «разбор» после ответа).
final class TaskOutcome {
  const TaskOutcome({required this.attempt, required this.task});

  /// Записанное событие.
  final TaskAttempt attempt;

  /// Задача — отсюда UI берёт `reveal` и верный ответ.
  final CognitiveTask task;
}

/// Иммутабельный снимок состояния движка на момент [nowMs].
///
/// Движок сам не измеряет время: [nowMs] — то, что хост передал в последнем
/// вызове. Оставшееся время — разность срока и [nowMs].
final class EngineState {
  const EngineState({
    required this.status,
    required this.nowMs,
    required this.totalBlocks,
    this.sessionId,
    this.startedAt,
    this.endedAt,
    this.phase,
    this.blockIndex,
    this.roundIndex,
    this.block,
    this.blockElapsedMs,
    this.blockRemainingMs,
    this.exerciseIndex,
    this.exercise,
    this.taskIndex,
    this.task,
    this.stage,
    this.stageRemainingMs,
    this.dueCues = const [],
    this.lastOutcome,
  });

  final EngineStatus status;

  /// Время последнего вызова хоста, мс эпохи UTC.
  final int nowMs;
  final int totalBlocks;

  final String? sessionId;
  final int? startedAt;

  /// `null` у идущей и у прерванной сессии.
  final int? endedAt;

  /// Текущая фаза; `null`, пока сессия не идёт.
  final Phase? phase;

  /// Позиция текущего блока в списке блоков.
  final int? blockIndex;

  /// Физическая фаза — `RoundLog.roundIndex`; когнитивная —
  /// `TaskAttempt.roundIndex`; у отдыха `null`.
  final int? roundIndex;

  /// Текущий блок плана.
  final PlannedBlock? block;

  /// Сколько идёт текущий блок.
  final int? blockElapsedMs;

  /// До срока блока; `null` у физического (его длительность не задана).
  final int? blockRemainingMs;

  // Физика.
  /// Позиция упражнения в круге (`ExerciseSet.setIndex`).
  final int? exerciseIndex;
  final PlannedExercise? exercise;

  // Когниция.
  final int? taskIndex;
  final PlannedTask? task;
  final TaskStage? stage;

  /// До ближайшего срока: у когнитивной задачи — min(срок стадии, срок
  /// блока); у упражнения в секундах — остаток; у повторений — `null`.
  final int? stageRemainingMs;

  /// Подсказки, чей момент уже наступил (инвариант 4: моменты — от сида).
  final List<DueCue> dueCues;

  /// Итог последней завершённой попытки; сохраняется до следующей.
  final TaskOutcome? lastOutcome;

  bool get isRunning => status == EngineStatus.running;
  bool get isFinished => status == EngineStatus.finished;
}
