import 'package:test/test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'support/fixtures.dart';

void main() {
  late TmbDatabase db;
  late SessionRepository inner;
  late InMemorySessionSummaryStore store;
  late SummaryRecordingSessionRepository repo;
  final errors = <Object>[];

  setUp(() {
    db = openMemoryDb();
    inner = DriftSessionRepository(db);
    store = InMemorySessionSummaryStore();
    errors.clear();
    repo = SummaryRecordingSessionRepository(
      inner,
      store,
      onError: (e, _) => errors.add(e),
    );
  });
  tearDown(() => db.close());

  group('InMemorySessionSummaryStore', () {
    test('пусто → write → read → clear', () async {
      expect(await store.read(), isNull);
      final snap = SessionSummarySnapshot.fromEvents(session: session(1));
      await store.write(snap);
      expect(await store.read(), snap);
      await store.clear();
      expect(await store.read(), isNull);
    });
  });

  group('recordSessionSummary', () {
    test('verbal не участвует в счётчиках (инвариант 7)', () async {
      final bundle = fullSession(100);
      final snap = await recordSessionSummary(store, bundle);
      // В фикстуре 5 попыток: choice, recall-таймаут, verbal, delayed, skipped.
      expect(bundle.attempts.length, 5);
      expect(snap.verifiableAttempts, 4);
      expect(snap.rounds, 2);
      expect(snap.setsTotal, 6);
      expect(snap.status, SessionSummaryStatus.completed);
      expect(await store.read(), snap);
    });

    test('прерванная сессия пишется со статусом aborted', () async {
      final snap = await recordSessionSummary(
        store,
        SessionBundle(session: session(1, endedAt: null)),
      );
      expect(snap.status, SessionSummaryStatus.aborted);
      expect(snap.durationMs, 0);
    });
  });

  group('SummaryRecordingSessionRepository', () {
    test('finishSession пишет сводку по сохранённым событиям', () async {
      final full = fullSession(100);
      final open = SessionBundle(
        session: session(100, endedAt: null),
        rounds: full.rounds,
        sets: full.sets,
        attempts: full.attempts,
      );
      await repo.saveSession(open);
      expect(await store.read(), isNull, reason: 'до завершения сводки нет');

      final endedAt = full.session.endedAt!;
      expect(
        await repo.finishSession(open.session.id, endedAt: endedAt),
        isTrue,
      );

      final snap = (await store.read())!;
      expect(snap.sessionId, open.session.id);
      expect(snap.status, SessionSummaryStatus.completed);
      expect(snap.durationMs, endedAt - open.session.startedAt);
      expect(snap.rounds, 2);
      expect(snap.verifiableAttempts, 4);
    });

    test('finishSession несуществующей сессии: false, сводки нет', () async {
      expect(await repo.finishSession(uuid(999), endedAt: 1), isFalse);
      await repo.settle();
      expect(await store.read(), isNull);
    });

    test('deleteSession стирает сводку только своей сессии', () async {
      final a = fullSession(100);
      final b = fullSession(200, startedAt: 1795200000000);
      await repo.saveSession(a);
      await repo.saveSession(b);
      await recordSessionSummary(store, b);

      await repo.deleteSession(a.session.id);
      await repo.settle();
      expect((await store.read())?.sessionId, b.session.id);

      await repo.deleteSession(b.session.id);
      await repo.settle();
      expect(await store.read(), isNull);
    });

    test('сбой хранилища не ломает finishSession', () async {
      final failing = SummaryRecordingSessionRepository(
        inner,
        _ThrowingStore(),
        onError: (e, _) => errors.add(e),
      );
      final open = SessionBundle(session: session(1, endedAt: null));
      final end = open.session.startedAt + 5000;
      await failing.saveSession(open);
      expect(
        await failing.finishSession(open.session.id, endedAt: end),
        isTrue,
      );
      await failing.settle();
      expect(errors, hasLength(1));
      expect((await inner.getSession(open.session.id))!.endedAt, end);
    });
  });
}

final class _ThrowingStore implements SessionSummaryStore {
  @override
  Future<void> write(SessionSummarySnapshot snapshot) =>
      Future.error(StateError('диск полон'));

  @override
  Future<SessionSummarySnapshot?> read() async => null;

  @override
  Future<void> clear() async {}
}
