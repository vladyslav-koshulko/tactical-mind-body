import '../common/json_reader.dart';
import 'exercise_set.dart';
import 'round_log.dart';
import 'session.dart';
import 'task_attempt.dart';

/// Плоский документ экспорта/синхронизации событий (SCHEMAS §3).
final class EventsExport {
  const EventsExport({
    this.schemaVersion = 1,
    this.sessions = const [],
    this.rounds = const [],
    this.sets = const [],
    this.attempts = const [],
  });

  factory EventsExport.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    expectKind(o, kind);
    return EventsExport(
      schemaVersion: o.integer('schemaVersion'),
      sessions: o.req(
        'sessions',
        listOf((v, p) => Session.read(convObject(v, p))),
      ),
      rounds: o.req(
        'rounds',
        listOf((v, p) => RoundLog.read(convObject(v, p))),
      ),
      sets: o.req('sets', listOf((v, p) => ExerciseSet.read(convObject(v, p)))),
      attempts: o.req(
        'attempts',
        listOf((v, p) => TaskAttempt.read(convObject(v, p))),
      ),
    );
  }

  /// Значение поля `kind`.
  static const kind = 'events_export';

  final int schemaVersion;
  final List<Session> sessions;
  final List<RoundLog> rounds;
  final List<ExerciseSet> sets;
  final List<TaskAttempt> attempts;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'kind': kind,
    'sessions': sessions.map((e) => e.toJson()).toList(),
    'rounds': rounds.map((e) => e.toJson()).toList(),
    'sets': sets.map((e) => e.toJson()).toList(),
    'attempts': attempts.map((e) => e.toJson()).toList(),
  };
}
