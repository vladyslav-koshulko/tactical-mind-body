import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

/// Сводка сессии для экрана итогов — только отображение сырых событий.
/// Это не Индекс и не счёт: клиент их не считает и не отправляет
/// (инвариант 8).
final class SessionStats {
  const SessionStats({
    required this.completed,
    required this.durationMs,
    required this.rounds,
    required this.setsTotal,
    required this.setsDone,
    required this.repsPlanned,
    required this.repsDone,
    required this.secondsPlanned,
    required this.secondsDone,
    required this.attempts,
    required this.correct,
    required this.wrong,
    required this.timeouts,
    required this.skipped,
    required this.verbalTotal,
    required this.verbalAnswered,
    required this.verbalAverageRating,
    required this.averageLatencyMs,
  });

  factory SessionStats.of(SessionBundle bundle) {
    final session = bundle.session;

    var setsDone = 0;
    var repsPlanned = 0;
    var repsDone = 0;
    var secondsPlanned = 0;
    var secondsDone = 0;
    for (final s in bundle.sets) {
      if (s.done > 0) setsDone++;
      switch (s.unit) {
        case ExerciseUnit.reps:
          repsPlanned += s.prescribed;
          repsDone += s.done;
        case ExerciseUnit.seconds:
          secondsPlanned += s.prescribed;
          secondsDone += s.done;
      }
    }

    var correct = 0;
    var wrong = 0;
    var timeouts = 0;
    var skipped = 0;
    var verbalTotal = 0;
    var verbalAnswered = 0;
    var ratingSum = 0;
    var latencySum = 0;
    var latencyCount = 0;
    for (final a in bundle.attempts) {
      if (!a.archetype.isMachineVerifiable) {
        verbalTotal++;
        if (a.status == AttemptStatus.answered) {
          verbalAnswered++;
          ratingSum += a.selfRating ?? 0;
        }
        continue;
      }
      switch (a.status) {
        case AttemptStatus.answered:
          if (a.isCorrect == true) {
            correct++;
          } else {
            wrong++;
          }
          final latency = a.latencyMs;
          if (latency != null) {
            latencySum += latency;
            latencyCount++;
          }
        case AttemptStatus.timeout:
          timeouts++;
        case AttemptStatus.skipped:
          skipped++;
      }
    }

    return SessionStats(
      completed: session.endedAt != null,
      durationMs: _durationMs(bundle),
      rounds: bundle.rounds.length,
      setsTotal: bundle.sets.length,
      setsDone: setsDone,
      repsPlanned: repsPlanned,
      repsDone: repsDone,
      secondsPlanned: secondsPlanned,
      secondsDone: secondsDone,
      attempts: bundle.attempts.length,
      correct: correct,
      wrong: wrong,
      timeouts: timeouts,
      skipped: skipped,
      verbalTotal: verbalTotal,
      verbalAnswered: verbalAnswered,
      verbalAverageRating: verbalAnswered == 0
          ? null
          : ratingSum / verbalAnswered,
      averageLatencyMs: latencyCount == 0
          ? null
          : (latencySum / latencyCount).round(),
    );
  }

  /// Сессию довели до конца (`Session.endedAt` записан).
  final bool completed;
  final int durationMs;
  final int rounds;

  final int setsTotal;

  /// Подходов, где сделано хоть что-то (`done > 0`).
  final int setsDone;
  final int repsPlanned;
  final int repsDone;
  final int secondsPlanned;
  final int secondsDone;

  final int attempts;

  /// Проверяемые задачи: ответ верен / неверен, таймаут, пропуск.
  final int correct;
  final int wrong;
  final int timeouts;
  final int skipped;

  /// `verbal` отдельно: машина их не проверяет (инвариант 7).
  final int verbalTotal;
  final int verbalAnswered;

  /// Средняя самооценка 0…3; `null`, если ни одной не было.
  final double? verbalAverageRating;

  /// Средняя задержка ответа на проверяемые задачи; `null`, если ответов нет.
  final int? averageLatencyMs;

  bool get hasVerifiable => correct + wrong + timeouts + skipped > 0;
  bool get hasPhysical => setsTotal > 0;

  /// Длительность: у завершённой — `endedAt − startedAt`; у прерванной
  /// `endedAt == null` (решение 32), конец восстанавливается по последнему
  /// событию; нет событий — 0.
  static int _durationMs(SessionBundle bundle) {
    final session = bundle.session;
    final ended = session.endedAt;
    if (ended != null) return ended - session.startedAt;
    var last = session.startedAt;
    for (final s in bundle.sets) {
      if (s.endedAt > last) last = s.endedAt;
    }
    for (final a in bundle.attempts) {
      final at = a.answeredAt ?? a.presentedAt;
      if (at > last) last = at;
    }
    return last - session.startedAt;
  }
}
