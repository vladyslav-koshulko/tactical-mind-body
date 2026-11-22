import 'dart:convert';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

const _sid = '62ed4258-a855-4484-9598-d5cc938f60f0';

// 2026-01-01T23:30:00Z; в поясе +180 это уже 2 января.
const _start = 1767310200000;

Session _session({int? endedAt = _start + 600000}) => Session(
  id: _sid,
  startedAt: _start,
  endedAt: endedAt,
  utcOffsetMin: 180,
  location: Location.home,
  difficulty: DifficultyLevel.fighter,
  template: SessionTemplateKind.dualTask,
  appVersion: '0.1.0+1',
);

RoundLog _round(int i) => RoundLog(
  id: 'r$i',
  sessionId: _sid,
  blockIndex: i * 2,
  roundIndex: i,
  durationMs: 60000,
  rpe: 2,
);

ExerciseSet _set(int i, {required int done, int endedAt = _start + 1000}) =>
    ExerciseSet(
      id: 's$i',
      sessionId: _sid,
      roundId: 'r0',
      setIndex: i,
      exerciseId: 'pushup',
      unit: ExerciseUnit.reps,
      prescribed: 15,
      done: done,
      startedAt: _start,
      endedAt: endedAt,
    );

TaskAttempt _attempt(
  int i, {
  TaskArchetype archetype = TaskArchetype.recall,
  AttemptStatus status = AttemptStatus.answered,
  bool? isCorrect = true,
  int? latencyMs = 1000,
  int? selfRating,
  int presentedAt = _start + 2000,
}) => TaskAttempt(
  id: 'a$i',
  sessionId: _sid,
  blockIndex: 1,
  roundIndex: 0,
  taskId: 't$i',
  packId: 'p',
  packSource: PackSource.builtin,
  archetype: archetype,
  domain: 'math',
  difficulty: 0.5,
  seed: i,
  status: status,
  presentedAt: presentedAt,
  answeredAt: latencyMs == null ? null : presentedAt + latencyMs,
  latencyMs: latencyMs,
  isCorrect: isCorrect,
  selfRating: selfRating,
  response: null,
  encodedRoundIndex: null,
  payloadHash: 'h$i',
);

void main() {
  group('SessionSummarySnapshot.fromEvents', () {
    test('завершённая: счётчики, точность, латентность', () {
      final snap = SessionSummarySnapshot.fromEvents(
        session: _session(),
        rounds: [_round(0), _round(1)],
        sets: [_set(0, done: 15), _set(1, done: 0), _set(2, done: 7)],
        attempts: [
          _attempt(0, latencyMs: 1000),
          _attempt(1, isCorrect: false, latencyMs: 2000),
          _attempt(
            2,
            status: AttemptStatus.timeout,
            isCorrect: null,
            latencyMs: null,
          ),
          _attempt(3, archetype: TaskArchetype.choice, latencyMs: 3000),
        ],
      );
      expect(snap.status, SessionSummaryStatus.completed);
      expect(snap.durationMs, 600000);
      expect(snap.rounds, 2);
      expect(snap.setsTotal, 3);
      expect(snap.setsDone, 2);
      expect(snap.verifiableAttempts, 4);
      expect(snap.correct, 2);
      expect(snap.accuracy, 0.5);
      expect(snap.averageLatencyMs, 2000);
      expect(snap.localDate, '2026-01-02');
    });

    test(
      'verbal не влияет ни на точность, ни на латентность (инвариант 7)',
      () {
        final base = [_attempt(0, latencyMs: 1000)];
        final withVerbal = [
          ...base,
          _attempt(
            1,
            archetype: TaskArchetype.verbal,
            isCorrect: null,
            selfRating: 3,
            latencyMs: 90000,
          ),
          _attempt(
            2,
            archetype: TaskArchetype.verbal,
            status: AttemptStatus.skipped,
            isCorrect: null,
            latencyMs: null,
          ),
        ];
        final a = SessionSummarySnapshot.fromEvents(
          session: _session(),
          attempts: base,
        );
        final b = SessionSummarySnapshot.fromEvents(
          session: _session(),
          attempts: withVerbal,
        );
        expect(b, a);
        expect(b.verifiableAttempts, 1);
      },
    );

    test('только verbal: точности и латентности нет', () {
      final snap = SessionSummarySnapshot.fromEvents(
        session: _session(),
        attempts: [
          _attempt(0, archetype: TaskArchetype.verbal, isCorrect: null),
        ],
      );
      expect(snap.verifiableAttempts, 0);
      expect(snap.accuracy, isNull);
      expect(snap.averageLatencyMs, isNull);
    });

    test('прервана: статус и длительность по последнему событию', () {
      final snap = SessionSummarySnapshot.fromEvents(
        session: _session(endedAt: null),
        sets: [_set(0, done: 5, endedAt: _start + 30000)],
        attempts: [_attempt(0, presentedAt: _start + 40000, latencyMs: 500)],
      );
      expect(snap.status, SessionSummaryStatus.aborted);
      expect(snap.durationMs, 40500);
    });

    test('пустая прерванная сессия: нули', () {
      final snap = SessionSummarySnapshot.fromEvents(
        session: _session(endedAt: null),
      );
      expect(snap.durationMs, 0);
      expect(snap.rounds, 0);
      expect(snap.accuracy, isNull);
    });
  });

  group('JSON', () {
    SessionSummarySnapshot sample() => SessionSummarySnapshot.fromEvents(
      session: _session(),
      rounds: [_round(0)],
      sets: [_set(0, done: 15)],
      attempts: [_attempt(0), _attempt(1, isCorrect: false, latencyMs: 2000)],
    );

    test('round-trip через строку JSON', () {
      final snap = sample();
      final back = SessionSummarySnapshot.fromJson(
        jsonDecode(jsonEncode(snap.toJson())) as Map<String, Object?>,
      );
      expect(back, snap);
    });

    test('round-trip: null-поля и aborted', () {
      final snap = SessionSummarySnapshot.fromEvents(
        session: _session(endedAt: null),
      );
      final back = SessionSummarySnapshot.fromJson(
        jsonDecode(jsonEncode(snap.toJson())) as Map<String, Object?>,
      );
      expect(back, snap);
      expect(back.toJson()['accuracy'], isNull);
      expect(back.toJson()['averageLatencyMs'], isNull);
    });

    test('формат: kind, версия, производные поля, wire-имена', () {
      final json = sample().toJson();
      expect(json['kind'], 'session_summary');
      expect(json['schemaVersion'], 1);
      expect(json['status'], 'completed');
      expect(json['localDate'], '2026-01-02');
      expect(json['accuracy'], 0.5);
      expect(
        json.keys.toSet(),
        containsAll(<String>['sessionId', 'rounds', 'setsDone', 'correct']),
      );
    });

    test('неизвестные поля игнорируются; производные пересчитываются', () {
      final json = Map<String, Object?>.of(sample().toJson())
        ..['future'] = 'x'
        ..['accuracy'] = 0.99;
      final back = SessionSummarySnapshot.fromJson(json);
      expect(back.accuracy, 0.5);
    });

    test('версия выше известной — FormatException', () {
      final json = Map<String, Object?>.of(sample().toJson())
        ..['schemaVersion'] = SessionSummarySnapshot.currentSchemaVersion + 1;
      expect(
        () => SessionSummarySnapshot.fromJson(json),
        throwsFormatException,
      );
    });

    test('чужой kind и битые поля — FormatException', () {
      final json = Map<String, Object?>.of(sample().toJson());
      expect(
        () =>
            SessionSummarySnapshot.fromJson({...json, 'kind': 'events_export'}),
        throwsFormatException,
      );
      expect(
        () => SessionSummarySnapshot.fromJson({...json, 'status': 'weird'}),
        throwsFormatException,
      );
      expect(
        () => SessionSummarySnapshot.fromJson({...json}..remove('rounds')),
        throwsFormatException,
      );
    });
  });
}
