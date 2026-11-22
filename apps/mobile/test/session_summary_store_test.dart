import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/data/session_summary_store.dart';

import 'helpers.dart';

const _sid = '62ed4258-a855-4484-9598-d5cc938f60f0';

final _session = Session(
  id: _sid,
  startedAt: fakeNowMs,
  endedAt: fakeNowMs + 900000,
  utcOffsetMin: 120,
  location: Location.home,
  difficulty: DifficultyLevel.fighter,
  template: SessionTemplateKind.dualTask,
  appVersion: '0.1.0+1',
);

void main() {
  group('SharedPreferencesSessionSummaryStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'write → read возвращает ту же сводку, ключ — контракт виджета',
      () async {
        final store = SharedPreferencesSessionSummaryStore();
        expect(await store.read(), isNull);

        final snap = SessionSummarySnapshot.fromEvents(session: _session);
        await store.write(snap);
        expect(await store.read(), snap);

        final raw = (await SharedPreferences.getInstance()).getString(
          'tmb.last_session_summary',
        );
        final json = jsonDecode(raw!) as Map<String, Object?>;
        expect(json['kind'], 'session_summary');
        expect(json['localDate'], '2026-01-01');
      },
    );

    test('новая запись перезаписывает старую; clear стирает', () async {
      final store = SharedPreferencesSessionSummaryStore();
      await store.write(SessionSummarySnapshot.fromEvents(session: _session));
      final second = SessionSummarySnapshot.fromEvents(
        session: Session(
          id: 'other',
          startedAt: fakeNowMs + 1,
          endedAt: null,
          utcOffsetMin: 0,
          location: Location.home,
          difficulty: DifficultyLevel.fighter,
          template: SessionTemplateKind.dualTask,
          appVersion: '0.1.0+1',
        ),
      );
      await store.write(second);
      expect((await store.read())!.sessionId, 'other');
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('битая и «слишком новая» запись читаются как null', () async {
      final store = SharedPreferencesSessionSummaryStore();
      SharedPreferences.setMockInitialValues({sessionSummaryKey: '{не json'});
      expect(await store.read(), isNull);

      final future = SessionSummarySnapshot.fromEvents(
        session: _session,
      ).toJson()..['schemaVersion'] = 99;
      SharedPreferences.setMockInitialValues({
        sessionSummaryKey: jsonEncode(future),
      });
      expect(await store.read(), isNull);
    });
  });

  group('провайдеры', () {
    test(
      'sessionRepositoryProvider: finishSession пишет сводку в хранилище',
      () async {
        final container = ProviderContainer(overrides: testOverrides());
        addTearDown(container.dispose);

        final repo = container.read(sessionRepositoryProvider);
        await repo.saveSession(
          SessionBundle(
            session: Session(
              id: _sid,
              startedAt: fakeNowMs,
              endedAt: null,
              utcOffsetMin: 120,
              location: Location.home,
              difficulty: DifficultyLevel.fighter,
              template: SessionTemplateKind.dualTask,
              appVersion: '0.1.0+1',
            ),
          ),
        );
        final store = container.read(sessionSummaryStoreProvider);
        expect(await store.read(), isNull);

        await repo.finishSession(_sid, endedAt: fakeNowMs + 900000);
        await (repo as SummaryRecordingSessionRepository).settle();
        final snap = (await store.read())!;
        expect(snap.sessionId, _sid);
        expect(snap.status, SessionSummaryStatus.completed);
        expect(snap.durationMs, 900000);
      },
    );

    test('тестовый стенд подменяет хранилище на in-memory', () {
      final container = ProviderContainer(overrides: testOverrides());
      addTearDown(container.dispose);
      expect(
        container.read(sessionSummaryStoreProvider),
        isA<InMemorySessionSummaryStore>(),
      );
    });
  });
}
