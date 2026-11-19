import 'package:drift/drift.dart';
import 'package:tmb_domain/tmb_domain.dart';

import '../database/tmb_database.dart';
import '../errors.dart';
import '../models/session_bundle.dart';
import 'session_repository.dart';

/// Реализация [SessionRepository] на Drift.
final class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db);

  final TmbDatabase _db;

  @override
  Future<void> saveSession(SessionBundle bundle) => _db.transaction(() async {
    await _db.into(_db.sessions).insert(_sessionCompanion(bundle.session));
    await _insertEvents(
      bundle.session.id,
      bundle.rounds,
      bundle.sets,
      bundle.attempts,
    );
  });

  @override
  Future<void> appendEvents(
    String sessionId, {
    Iterable<RoundLog> rounds = const [],
    Iterable<ExerciseSet> sets = const [],
    Iterable<TaskAttempt> attempts = const [],
  }) => _db.transaction(() => _insertEvents(sessionId, rounds, sets, attempts));

  /// Круги пишутся раньше подходов: подход ссылается на `roundId` (FK).
  Future<void> _insertEvents(
    String sessionId,
    Iterable<RoundLog> rounds,
    Iterable<ExerciseSet> sets,
    Iterable<TaskAttempt> attempts,
  ) async {
    void requireSame(String id, String actual, String what) {
      if (actual != sessionId) {
        throw InconsistentEventsException(
          '$what $id принадлежит сессии $actual, а не $sessionId.',
        );
      }
    }

    for (final r in rounds) {
      requireSame(r.id, r.sessionId, 'Круг');
    }
    for (final s in sets) {
      requireSame(s.id, s.sessionId, 'Подход');
    }
    for (final a in attempts) {
      requireSame(a.id, a.sessionId, 'Попытка');
    }
    await _db.batch((b) {
      b.insertAll(_db.roundLogs, rounds.map(_roundCompanion));
      b.insertAll(_db.exerciseSets, sets.map(_setCompanion));
      b.insertAll(_db.taskAttempts, attempts.map(_attemptCompanion));
    });
  }

  @override
  Future<bool> finishSession(String sessionId, {required int endedAt}) async {
    final n =
        await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
            .write(SessionsCompanion(endedAt: Value(endedAt)));
    return n > 0;
  }

  @override
  Future<bool> deleteSession(String sessionId) async {
    final n = await (_db.delete(
      _db.sessions,
    )..where((t) => t.id.equals(sessionId))).go();
    return n > 0;
  }

  SimpleSelectStatement<$SessionsTable, SessionRow> _newestSessions(
    int limit,
    int offset,
  ) => _db.select(_db.sessions)
    ..orderBy([
      (t) => OrderingTerm.desc(t.startedAt),
      (t) => OrderingTerm.asc(t.id),
    ])
    ..limit(limit, offset: offset);

  @override
  Future<List<Session>> listSessions({int limit = 50, int offset = 0}) async {
    final rows = await _newestSessions(limit, offset).get();
    return rows.map(_session).toList();
  }

  @override
  Stream<List<Session>> watchSessions({int limit = 50}) => _newestSessions(
    limit,
    0,
  ).watch().map((rows) => rows.map(_session).toList());

  @override
  Future<Session?> getSession(String sessionId) async {
    final row = await (_db.select(
      _db.sessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    return row == null ? null : _session(row);
  }

  @override
  Future<List<RoundLog>> roundsOf(String sessionId) async {
    final rows =
        await (_db.select(_db.roundLogs)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.roundIndex),
                (t) => OrderingTerm.asc(t.blockIndex),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_round).toList();
  }

  @override
  Future<List<ExerciseSet>> setsOf(String sessionId) async {
    final rows =
        await (_db.select(_db.exerciseSets)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.startedAt),
                (t) => OrderingTerm.asc(t.setIndex),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_set).toList();
  }

  @override
  Future<List<TaskAttempt>> attemptsOf(String sessionId) async {
    final rows =
        await (_db.select(_db.taskAttempts)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.presentedAt),
                (t) => OrderingTerm.asc(t.blockIndex),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_attempt).toList();
  }

  @override
  Future<SessionBundle?> loadSession(String sessionId) =>
      _db.transaction(() async {
        final session = await getSession(sessionId);
        if (session == null) return null;
        return SessionBundle(
          session: session,
          rounds: await roundsOf(sessionId),
          sets: await setsOf(sessionId),
          attempts: await attemptsOf(sessionId),
        );
      });

  @override
  Future<List<ExerciseSet>> recentSets(
    String exerciseId, {
    int limit = 10,
  }) async {
    final rows =
        await (_db.select(_db.exerciseSets)
              ..where((t) => t.exerciseId.equals(exerciseId))
              ..orderBy([
                (t) => OrderingTerm.desc(t.startedAt),
                (t) => OrderingTerm.desc(t.setIndex),
                (t) => OrderingTerm.asc(t.id),
              ])
              ..limit(limit))
            .get();
    return rows.map(_set).toList();
  }

  @override
  Future<EventsExport> exportEvents() => _db.transaction(() async {
    // Один снимок: транзакция исключает «разъехавшиеся» таблицы в экспорте.
    final sessions =
        await (_db.select(_db.sessions)..orderBy([
              (t) => OrderingTerm.asc(t.startedAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final rounds =
        await (_db.select(_db.roundLogs)..orderBy([
              (t) => OrderingTerm.asc(t.sessionId),
              (t) => OrderingTerm.asc(t.roundIndex),
              (t) => OrderingTerm.asc(t.blockIndex),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final sets =
        await (_db.select(_db.exerciseSets)..orderBy([
              (t) => OrderingTerm.asc(t.startedAt),
              (t) => OrderingTerm.asc(t.setIndex),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final attempts =
        await (_db.select(_db.taskAttempts)..orderBy([
              (t) => OrderingTerm.asc(t.presentedAt),
              (t) => OrderingTerm.asc(t.blockIndex),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    return EventsExport(
      sessions: sessions.map(_session).toList(),
      rounds: rounds.map(_round).toList(),
      sets: sets.map(_set).toList(),
      attempts: attempts.map(_attempt).toList(),
    );
  });
}

// ---- Domain → Companion ----

SessionsCompanion _sessionCompanion(Session s) => SessionsCompanion.insert(
  id: s.id,
  startedAt: s.startedAt,
  endedAt: Value(s.endedAt),
  utcOffsetMin: s.utcOffsetMin,
  location: s.location.wire,
  difficulty: s.difficulty.wire,
  template: s.template.wire,
  appVersion: s.appVersion,
);

RoundLogsCompanion _roundCompanion(RoundLog r) => RoundLogsCompanion.insert(
  id: r.id,
  sessionId: r.sessionId,
  blockIndex: r.blockIndex,
  roundIndex: r.roundIndex,
  durationMs: r.durationMs,
  rpe: Value(r.rpe),
);

ExerciseSetsCompanion _setCompanion(ExerciseSet s) =>
    ExerciseSetsCompanion.insert(
      id: s.id,
      sessionId: s.sessionId,
      roundId: s.roundId,
      setIndex: s.setIndex,
      exerciseId: s.exerciseId,
      unit: s.unit.wire,
      prescribed: s.prescribed,
      done: s.done,
      startedAt: s.startedAt,
      endedAt: s.endedAt,
    );

TaskAttemptsCompanion _attemptCompanion(TaskAttempt a) =>
    TaskAttemptsCompanion.insert(
      id: a.id,
      sessionId: a.sessionId,
      blockIndex: a.blockIndex,
      roundIndex: a.roundIndex,
      taskId: a.taskId,
      packId: a.packId,
      packSource: a.packSource.wire,
      archetype: a.archetype.wire,
      domain: a.domain,
      difficulty: a.difficulty,
      seed: a.seed,
      status: a.status.wire,
      presentedAt: a.presentedAt,
      answeredAt: Value(a.answeredAt),
      latencyMs: Value(a.latencyMs),
      isCorrect: Value(a.isCorrect),
      selfRating: Value(a.selfRating),
      response: Value(a.response),
      encodedRoundIndex: Value(a.encodedRoundIndex),
      payloadHash: a.payloadHash,
    );

// ---- Row → Domain ----

Session _session(SessionRow r) => Session(
  id: r.id,
  startedAt: r.startedAt,
  endedAt: r.endedAt,
  utcOffsetMin: r.utcOffsetMin,
  location: parseWire(Location.values, r.location, 'sessions.location'),
  difficulty: parseWire(
    DifficultyLevel.values,
    r.difficulty,
    'sessions.difficulty',
  ),
  template: parseWire(
    SessionTemplateKind.values,
    r.template,
    'sessions.template',
  ),
  appVersion: r.appVersion,
);

RoundLog _round(RoundLogRow r) => RoundLog(
  id: r.id,
  sessionId: r.sessionId,
  blockIndex: r.blockIndex,
  roundIndex: r.roundIndex,
  durationMs: r.durationMs,
  rpe: r.rpe,
);

ExerciseSet _set(ExerciseSetRow r) => ExerciseSet(
  id: r.id,
  sessionId: r.sessionId,
  roundId: r.roundId,
  setIndex: r.setIndex,
  exerciseId: r.exerciseId,
  unit: parseWire(ExerciseUnit.values, r.unit, 'exercise_sets.unit'),
  prescribed: r.prescribed,
  done: r.done,
  startedAt: r.startedAt,
  endedAt: r.endedAt,
);

TaskAttempt _attempt(TaskAttemptRow r) => TaskAttempt(
  id: r.id,
  sessionId: r.sessionId,
  blockIndex: r.blockIndex,
  roundIndex: r.roundIndex,
  taskId: r.taskId,
  packId: r.packId,
  packSource: parseWire(
    PackSource.values,
    r.packSource,
    'task_attempts.pack_source',
  ),
  archetype: parseWire(
    TaskArchetype.values,
    r.archetype,
    'task_attempts.archetype',
  ),
  domain: r.domain,
  difficulty: r.difficulty,
  seed: r.seed,
  status: parseWire(AttemptStatus.values, r.status, 'task_attempts.status'),
  presentedAt: r.presentedAt,
  answeredAt: r.answeredAt,
  latencyMs: r.latencyMs,
  isCorrect: r.isCorrect,
  selfRating: r.selfRating,
  response: r.response,
  encodedRoundIndex: r.encodedRoundIndex,
  payloadHash: r.payloadHash,
);
