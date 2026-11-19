import 'dart:convert';

import 'package:test/test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'support/fixtures.dart';

void main() {
  late TmbDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = openMemoryDb();
    repo = DriftSessionRepository(db);
  });
  tearDown(() => db.close());

  Future<List<int>> counts() async => [
    (await db.select(db.sessions).get()).length,
    (await db.select(db.roundLogs).get()).length,
    (await db.select(db.exerciseSets).get()).length,
    (await db.select(db.taskAttempts).get()).length,
  ];

  group('round-trip', () {
    test('сессия, круги, подходы и попытки читаются как записаны', () async {
      final b = fullSession(100);
      await repo.saveSession(b);

      final loaded = (await repo.loadSession(b.session.id))!;
      expect(loaded.session.toJson(), b.session.toJson());
      expect(jsons(loaded.rounds), jsons(b.rounds));
      expect(jsons(loaded.sets), jsons(b.sets));
      expect(jsons(loaded.attempts), jsons(b.attempts));
    });

    test('прерванная сессия: endedAt == null сохраняется', () async {
      final s = session(1, endedAt: null);
      await repo.saveSession(SessionBundle(session: s));
      expect((await repo.getSession(s.id))!.endedAt, isNull);
    });

    test('RoundLog: rpe 1, 2, 3 и null', () async {
      final s = session(1);
      final rounds = [
        for (var i = 0; i < 4; i++)
          round(
            10 + i,
            s.id,
            blockIndex: i,
            roundIndex: i,
            rpe: [1, 2, 3, null][i],
          ),
      ];
      await repo.saveSession(SessionBundle(session: s, rounds: rounds));
      expect((await repo.roundsOf(s.id)).map((r) => r.rpe), [1, 2, 3, null]);
    });

    test('ExerciseSet: обе единицы и ноль выполненного', () async {
      final s = session(1);
      final r = round(2, s.id);
      final sets = [
        exerciseSet(3, s.id, r.id, done: 0),
        exerciseSet(
          4,
          s.id,
          r.id,
          setIndex: 1,
          unit: ExerciseUnit.seconds,
          prescribed: 3600,
          done: 3600,
        ),
      ];
      await repo.saveSession(
        SessionBundle(session: s, rounds: [r], sets: sets),
      );
      expect(jsons(await repo.setsOf(s.id)), jsons(sets));
    });

    test(
      'TaskAttempt: все статусы, все поля сырых событий (инвариант 2)',
      () async {
        final s = session(1);
        final attempts = [
          answered(10, s.id),
          timedOut(11, s.id, presentedAt: 1795100300000),
          skipped(12, s.id, presentedAt: 1795100400000),
          verbal(13, s.id, presentedAt: 1795100500000),
          delayed(14, s.id, presentedAt: 1795100600000),
        ];
        await repo.saveSession(SessionBundle(session: s, attempts: attempts));
        final back = await repo.attemptsOf(s.id);
        expect(jsons(back), jsons(attempts));

        final a = back.first;
        expect(a.roundIndex, 0);
        expect(a.latencyMs, 7391);
        expect(a.isCorrect, isTrue);
        expect(a.payloadHash, hash(10));
        expect(back.firstWhere((x) => x.id == uuid(13)).isCorrect, isNull);
        expect(back.firstWhere((x) => x.id == uuid(14)).encodedRoundIndex, 0);
      },
    );

    test('difficulty и максимальный seed 2^53−1 без потерь', () async {
      final s = session(1);
      final a = answered(10, s.id, difficulty: 0.35, seed: maxSafeSeed);
      await repo.saveSession(SessionBundle(session: s, attempts: [a]));
      final back = (await repo.attemptsOf(s.id)).single;
      expect(back.difficulty, 0.35);
      expect(back.seed, maxSafeSeed);
    });

    test('несуществующая сессия: null', () async {
      expect(await repo.getSession(uuid(9)), isNull);
      expect(await repo.loadSession(uuid(9)), isNull);
    });
  });

  group('транзакционность', () {
    test('дубль id попытки в конце пакета — не сохранено ничего', () async {
      final b = fullSession(100);
      final bad = SessionBundle(
        session: b.session,
        rounds: b.rounds,
        sets: b.sets,
        attempts: [...b.attempts, b.attempts.first],
      );
      await expectLater(repo.saveSession(bad), throwsA(anything));
      expect(await counts(), [0, 0, 0, 0]);
    });

    test('подход со ссылкой на несуществующий круг (FK) — откат', () async {
      final s = session(1);
      final r = round(2, s.id);
      final bad = SessionBundle(
        session: s,
        rounds: [r],
        sets: [exerciseSet(3, s.id, r.id), exerciseSet(4, s.id, uuid(999))],
        attempts: [answered(10, s.id)],
      );
      await expectLater(repo.saveSession(bad), throwsA(anything));
      expect(await counts(), [0, 0, 0, 0]);
    });

    test('нарушение CHECK (answered без latencyMs) — откат', () async {
      final s = session(1);
      final broken = TaskAttempt(
        id: uuid(11),
        sessionId: s.id,
        blockIndex: 1,
        roundIndex: 0,
        taskId: 'demo.java.002',
        packId: 'demo.ru',
        packSource: PackSource.builtin,
        archetype: TaskArchetype.choice,
        domain: 'it.java',
        difficulty: 0.3,
        seed: 1,
        status: AttemptStatus.answered,
        presentedAt: 1795100220000,
        answeredAt: 1795100227400,
        latencyMs: null,
        isCorrect: true,
        selfRating: null,
        response: '2',
        encodedRoundIndex: null,
        payloadHash: hash(11),
      );
      await expectLater(
        repo.saveSession(
          SessionBundle(
            session: s,
            rounds: [round(2, s.id)],
            attempts: [answered(10, s.id), broken],
          ),
        ),
        throwsA(anything),
      );
      expect(await counts(), [0, 0, 0, 0]);
    });

    test('событие чужой сессии — InconsistentEventsException, откат', () async {
      final s = session(1);
      await expectLater(
        repo.saveSession(
          SessionBundle(
            session: s,
            attempts: [answered(10, s.id), answered(11, uuid(2))],
          ),
        ),
        throwsA(isA<InconsistentEventsException>()),
      );
      expect(await counts(), [0, 0, 0, 0]);
    });

    test('повторная запись той же сессии не портит уже сохранённую', () async {
      final b = fullSession(100);
      await repo.saveSession(b);
      await expectLater(repo.saveSession(b), throwsA(anything));
      expect(await counts(), [1, 2, 6, 5]);
    });

    test('appendEvents: ошибка посреди пакета откатывает весь пакет', () async {
      final s = session(1, endedAt: null);
      await repo.saveSession(SessionBundle(session: s));
      await expectLater(
        repo.appendEvents(
          s.id,
          rounds: [round(2, s.id)],
          attempts: [answered(10, s.id), answered(10, s.id)],
        ),
        throwsA(anything),
      );
      expect(await counts(), [1, 0, 0, 0]);
    });

    test('внешние ключи включены: события без сессии не пишутся', () async {
      await expectLater(
        repo.appendEvents(uuid(77), attempts: [answered(10, uuid(77))]),
        throwsA(anything),
      );
      expect(await counts(), [0, 0, 0, 0]);
    });
  });

  group('запись по ходу сессии', () {
    test('appendEvents + finishSession', () async {
      final s = session(1, endedAt: null);
      await repo.saveSession(SessionBundle(session: s));
      final r = round(2, s.id);
      await repo.appendEvents(
        s.id,
        rounds: [r],
        sets: [exerciseSet(3, s.id, r.id)],
      );
      await repo.appendEvents(s.id, attempts: [answered(10, s.id)]);

      expect((await repo.getSession(s.id))!.endedAt, isNull);
      expect(
        await repo.finishSession(s.id, endedAt: s.startedAt + 1000),
        isTrue,
      );
      expect((await repo.getSession(s.id))!.endedAt, s.startedAt + 1000);
      expect(await counts(), [1, 1, 1, 1]);
      expect(await repo.finishSession(uuid(55), endedAt: 1), isFalse);
    });

    test('deleteSession каскадом удаляет все события', () async {
      final a = fullSession(100);
      final b = fullSession(200, startedAt: 1795200000000);
      await repo.saveSession(a);
      await repo.saveSession(b);

      expect(await repo.deleteSession(a.session.id), isTrue);
      expect(await counts(), [1, 2, 6, 5]);
      expect(await repo.loadSession(a.session.id), isNull);
      expect(await repo.deleteSession(a.session.id), isFalse);
    });
  });

  group('история и порядок', () {
    test(
      'listSessions: новые первыми, равное время — по id, limit/offset',
      () async {
        final sessions = [
          session(3, startedAt: 3000),
          session(1, startedAt: 1000),
          session(5, startedAt: 5000),
          session(4, startedAt: 3000),
          session(2, startedAt: 2000),
        ];
        for (final s in sessions) {
          await repo.saveSession(SessionBundle(session: s));
        }

        final all = await repo.listSessions();
        expect(all.map((s) => s.id), [
          uuid(5),
          uuid(3),
          uuid(4),
          uuid(2),
          uuid(1),
        ]);
        expect((await repo.listSessions(limit: 2)).map((s) => s.id), [
          uuid(5),
          uuid(3),
        ]);
        expect(
          (await repo.listSessions(limit: 2, offset: 2)).map((s) => s.id),
          [uuid(4), uuid(2)],
        );
        expect(await repo.listSessions(offset: 10), isEmpty);
      },
    );

    test('watchSessions обновляется при записи', () async {
      final events = <List<String>>[];
      final sub = repo.watchSessions().listen(
        (l) => events.add([for (final s in l) s.id]),
      );
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await repo.saveSession(SessionBundle(session: session(1)));
      await pumpEventQueue();
      expect(events.first, isEmpty);
      expect(events.last, [uuid(1)]);
    });

    test('события сессии читаются в порядке круг → подход → попытка', () async {
      final s = session(1);
      final r1 = round(21, s.id, blockIndex: 2, roundIndex: 1);
      final r0 = round(22, s.id, blockIndex: 0, roundIndex: 0);
      await repo.saveSession(
        SessionBundle(
          session: s,
          // Нарочно записаны в обратном порядке.
          rounds: [r1, r0],
          sets: [
            exerciseSet(33, s.id, r0.id, setIndex: 1, startedAt: 2000),
            exerciseSet(32, s.id, r0.id, setIndex: 0, startedAt: 2000),
            exerciseSet(31, s.id, r0.id, setIndex: 0, startedAt: 1000),
          ],
          attempts: [
            answered(43, s.id, presentedAt: 3000),
            answered(42, s.id, presentedAt: 1000),
            answered(41, s.id, presentedAt: 2000),
          ],
        ),
      );
      expect((await repo.roundsOf(s.id)).map((r) => r.roundIndex), [0, 1]);
      expect((await repo.setsOf(s.id)).map((e) => e.id), [
        uuid(31),
        uuid(32),
        uuid(33),
      ]);
      expect((await repo.attemptsOf(s.id)).map((a) => a.id), [
        uuid(42),
        uuid(41),
        uuid(43),
      ]);
    });

    test('recentSets: последние N подхода упражнения, новые первыми', () async {
      final s1 = session(1, startedAt: 1000);
      final s2 = session(2, startedAt: 100000);
      final r1 = round(11, s1.id);
      final r2 = round(12, s2.id);
      await repo.saveSession(
        SessionBundle(
          session: s1,
          rounds: [r1],
          sets: [
            exerciseSet(21, s1.id, r1.id, startedAt: 1000, done: 10),
            exerciseSet(22, s1.id, r1.id, startedAt: 2000, done: 11),
            exerciseSet(
              23,
              s1.id,
              r1.id,
              startedAt: 1500,
              exerciseId: 'ex.plank',
              unit: ExerciseUnit.seconds,
              prescribed: 30,
              done: 30,
            ),
          ],
        ),
      );
      await repo.saveSession(
        SessionBundle(
          session: s2,
          rounds: [r2],
          sets: [
            exerciseSet(24, s2.id, r2.id, startedAt: 100000, done: 13),
            exerciseSet(25, s2.id, r2.id, startedAt: 101000, done: 14),
          ],
        ),
      );

      final last3 = await repo.recentSets('ex.pushup', limit: 3);
      expect(last3.map((e) => e.done), [14, 13, 11]);
      expect(last3.every((e) => e.exerciseId == 'ex.pushup'), isTrue);
      expect(await repo.recentSets('ex.pushup', limit: 100), hasLength(4));
      expect(
        (await repo.recentSets('ex.plank')).single.unit,
        ExerciseUnit.seconds,
      );
      expect(await repo.recentSets('ex.nothing'), isEmpty);
    });
  });

  group('экспорт', () {
    test('пустая БД даёт валидный пустой events_export', () async {
      final export = await repo.exportEvents();
      expect(export.sessions, isEmpty);
      final r = validateExport(export);
      expect(r.isDocumentRejected, isFalse);
      expect(r.issues, isEmpty);
    });

    test('все события экспортируются и проходят events_validator', () async {
      final a = fullSession(100);
      final b = fullSession(200, startedAt: 1795200000000);
      // Сохраняем в «неправильном» порядке: порядок экспорта от этого не зависит.
      await repo.saveSession(b);
      await repo.saveSession(a);
      await repo.saveSession(
        SessionBundle(
          session: session(300, startedAt: 1795300000000, endedAt: null),
        ),
      );

      final export = await repo.exportEvents();
      expect(export.schemaVersion, 1);
      expect(export.sessions.map((s) => s.id), [
        a.session.id,
        b.session.id,
        uuid(300),
      ]);
      expect(export.rounds, hasLength(4));
      expect(export.sets, hasLength(12));
      expect(export.attempts, hasLength(10));

      final result = validateExport(export);
      expect(result.isDocumentRejected, isFalse);
      expect(result.errors, isEmpty, reason: '${result.issues}');
      expect(result.issues, isEmpty);
      expect(result.excluded, isEmpty);
      expect(result.eventsExport!.attempts, hasLength(10));
    });

    test('экспорт переживает JSON-сериализацию без потерь', () async {
      final b = fullSession(100);
      await repo.saveSession(b);
      final export = await repo.exportEvents();

      final wire =
          jsonDecode(jsonEncode(export.toJson())) as Map<String, Object?>;
      final back = EventsExport.fromJson(wire);
      expect(back.toJson(), export.toJson());
      expect(jsons(back.attempts), jsons(b.attempts));
      expect(wire['kind'], 'events_export');
    });

    test('сырые поля инварианта 2 есть в каждой попытке экспорта', () async {
      await repo.saveSession(fullSession(100));
      final wire = (await repo.exportEvents()).toJson();
      for (final a
          in (wire['attempts']! as List).cast<Map<String, Object?>>()) {
        expect(
          a.keys,
          containsAll([
            'roundIndex',
            'latencyMs',
            'isCorrect',
            'payloadHash',
            'seed',
          ]),
        );
      }
    });
  });
}

const maxSafeSeed = 9007199254740991;
