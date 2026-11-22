import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/dashboard/dashboard_screen.dart';
import 'package:tmb_mobile/features/session/session_stats.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../helpers.dart';
import 'session_kit.dart';

const _sid = '11111111-1111-4111-8111-111111111111';
const _rid1 = '22222222-2222-4222-8222-222222222221';

Session _session({int? endedAt}) => Session(
  id: _sid,
  startedAt: fakeNowMs,
  endedAt: endedAt,
  utcOffsetMin: 0,
  location: Location.home,
  difficulty: DifficultyLevel.recruit,
  template: SessionTemplateKind.dualTask,
  appVersion: '0.1.0',
);

var _n = 0;
String _uuid() {
  _n++;
  final hex = _n.toRadixString(16).padLeft(12, '0');
  return '33333333-3333-4333-8333-$hex';
}

TaskAttempt _attempt({
  required TaskArchetype archetype,
  required AttemptStatus status,
  bool? isCorrect,
  int? latencyMs,
  int? selfRating,
}) {
  final answered = status == AttemptStatus.answered;
  return TaskAttempt(
    id: _uuid(),
    sessionId: _sid,
    blockIndex: 1,
    roundIndex: 0,
    taskId: 't$_n',
    packId: 'test.pack',
    packSource: PackSource.builtin,
    archetype: archetype,
    domain: 'cog.test.x',
    difficulty: 0.5,
    seed: 1,
    status: status,
    presentedAt: fakeNowMs + 1000,
    answeredAt: answered ? fakeNowMs + 1000 + (latencyMs ?? 0) : null,
    latencyMs: answered ? latencyMs : null,
    isCorrect: archetype == TaskArchetype.verbal ? null : isCorrect,
    selfRating: selfRating,
    response: null,
    encodedRoundIndex: null,
    payloadHash: 'a' * 64,
  );
}

ExerciseSet _set(int index, ExerciseUnit unit, int prescribed, int done) =>
    ExerciseSet(
      id: _uuid(),
      sessionId: _sid,
      roundId: _rid1,
      setIndex: index,
      exerciseId: 'ex.test_a',
      unit: unit,
      prescribed: prescribed,
      done: done,
      startedAt: fakeNowMs + index * 1000,
      endedAt: fakeNowMs + (index + 1) * 1000,
    );

SessionBundle _fullBundle() => SessionBundle(
  session: _session(endedAt: fakeNowMs + 65000),
  rounds: const [
    RoundLog(
      id: _rid1,
      sessionId: _sid,
      blockIndex: 0,
      roundIndex: 0,
      durationMs: 3000,
      rpe: 2,
    ),
  ],
  sets: [
    _set(0, ExerciseUnit.reps, 15, 15),
    _set(1, ExerciseUnit.reps, 15, 10),
    _set(2, ExerciseUnit.seconds, 30, 0),
  ],
  attempts: [
    _attempt(
      archetype: TaskArchetype.recall,
      status: AttemptStatus.answered,
      isCorrect: true,
      latencyMs: 3000,
    ),
    _attempt(
      archetype: TaskArchetype.choice,
      status: AttemptStatus.answered,
      isCorrect: true,
      latencyMs: 5000,
    ),
    _attempt(
      archetype: TaskArchetype.recall,
      status: AttemptStatus.answered,
      isCorrect: false,
      latencyMs: 7000,
    ),
    _attempt(
      archetype: TaskArchetype.spatial,
      status: AttemptStatus.timeout,
      isCorrect: false,
    ),
    _attempt(
      archetype: TaskArchetype.ordering,
      status: AttemptStatus.skipped,
      isCorrect: false,
    ),
    // verbal: считаются отдельно и в задержку не входят.
    _attempt(
      archetype: TaskArchetype.verbal,
      status: AttemptStatus.answered,
      latencyMs: 90000,
      selfRating: 3,
    ),
    _attempt(
      archetype: TaskArchetype.verbal,
      status: AttemptStatus.answered,
      latencyMs: 60000,
      selfRating: 2,
    ),
    _attempt(archetype: TaskArchetype.verbal, status: AttemptStatus.timeout),
  ],
);

/// Значение строки итогов по её подписи.
Finder _valueOf(String label, String value) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
  matching: find.text(value),
);

Future<SessionEnv> _pumpSummary(
  WidgetTester tester, {
  String id = _sid,
  SessionBundle? bundle,
  Size size = const Size(360, 800),
  double textScale = 1,
}) => pumpSession(
  tester,
  tasks: [recallNumeric],
  initialLocation: TmbRoutes.summaryOf(id),
  size: size,
  textScale: textScale,
  seedDb: (db) async {
    if (bundle != null) await DriftSessionRepository(db).saveSession(bundle);
  },
);

void main() {
  group('SessionStats', () {
    test('считает по сырым событиям; verbal отдельно и без задержки', () {
      final s = SessionStats.of(_fullBundle());
      expect(s.completed, isTrue);
      expect(s.durationMs, 65000);
      expect(s.rounds, 1);
      expect((s.setsDone, s.setsTotal), (2, 3));
      expect((s.repsDone, s.repsPlanned), (25, 30));
      expect((s.secondsDone, s.secondsPlanned), (0, 30));
      expect((s.correct, s.wrong, s.timeouts, s.skipped), (2, 1, 1, 1));
      expect((s.verbalAnswered, s.verbalTotal), (2, 3));
      expect(s.verbalAverageRating, 2.5);
      expect(s.averageLatencyMs, 5000); // (3000 + 5000 + 7000) / 3
    });

    test('пустая прерванная сессия: нули и null, без исключений', () {
      final s = SessionStats.of(SessionBundle(session: _session()));
      expect(s.completed, isFalse);
      expect(s.durationMs, 0);
      expect(s.averageLatencyMs, isNull);
      expect(s.verbalAverageRating, isNull);
      expect(s.hasPhysical, isFalse);
      expect(s.hasVerifiable, isFalse);
    });

    test('прервана: конец — по последнему событию', () {
      final s = SessionStats.of(
        SessionBundle(
          session: _session(),
          sets: [_set(0, ExerciseUnit.reps, 15, 15)],
        ),
      );
      expect(s.durationMs, 1000);
    });
  });

  testWidgets('итоги: длительность, круги, подходы, задачи, задержка', (
    tester,
  ) async {
    final env = await _pumpSummary(tester, bundle: _fullBundle());
    expect(find.text(l10n.sessionSummaryTitle.toUpperCase()), findsOneWidget);
    expect(
      find.text(l10n.sessionSummaryStatusCompleted.toUpperCase()),
      findsOneWidget,
    );

    expect(_valueOf(l10n.sessionSummaryDuration, '01:05'), findsOneWidget);
    expect(_valueOf(l10n.sessionSummaryRounds, '1'), findsOneWidget);
    expect(
      _valueOf(l10n.sessionSummarySets, l10n.sessionSummaryOutOf(2, 3)),
      findsOneWidget,
    );
    expect(
      _valueOf(l10n.sessionSummaryReps, l10n.sessionSummaryFactPlan(25, 30)),
      findsOneWidget,
    );
    expect(
      _valueOf(l10n.sessionSummarySeconds, l10n.sessionSummaryFactPlan(0, 30)),
      findsOneWidget,
    );
    expect(_valueOf(l10n.sessionSummaryCorrect, '2'), findsOneWidget);
    expect(_valueOf(l10n.sessionSummaryWrong, '1'), findsOneWidget);
    expect(_valueOf(l10n.sessionSummaryTimeout, '1'), findsOneWidget);
    expect(_valueOf(l10n.sessionSummarySkipped, '1'), findsOneWidget);
    expect(
      _valueOf(
        l10n.sessionSummaryLatency,
        l10n.sessionSummarySecondsValue('5.0'),
      ),
      findsOneWidget,
    );
    // verbal — отдельная секция с самооценкой.
    expect(find.text(l10n.sessionSummaryVerbal.toUpperCase()), findsOneWidget);
    expect(
      _valueOf(l10n.sessionSummaryVerbalDone, l10n.sessionSummaryOutOf(2, 3)),
      findsOneWidget,
    );
    expect(
      _valueOf(
        l10n.sessionSummaryVerbalRating,
        l10n.sessionSummaryRatingValue('2.5'),
      ),
      findsOneWidget,
    );
    // Клиент ничего не отправляет и не считает в зачёт: ни Индекса, ни кнопок «отправить».
    expect(
      find.byType(TmbButton).evaluate().length,
      1,
      reason: 'одна кнопка — «на дашборд»',
    );

    await tester.tap(find.text(l10n.sessionSummaryToDashboard.toUpperCase()));
    await env.settle(8);
    expect(find.byType(DashboardScreen), findsOneWidget);
    await env.unmount();
  });

  testWidgets('прерванная без событий: корректные прочерки', (tester) async {
    final env = await _pumpSummary(
      tester,
      bundle: SessionBundle(session: _session()),
    );
    expect(
      find.text(l10n.sessionSummaryStatusAborted.toUpperCase()),
      findsOneWidget,
    );
    expect(_valueOf(l10n.sessionSummaryDuration, '00:00'), findsOneWidget);
    expect(
      _valueOf(l10n.sessionSummaryRounds, l10n.sessionSummaryNone),
      findsOneWidget,
    );
    expect(
      _valueOf(l10n.sessionSummarySets, l10n.sessionSummaryNone),
      findsOneWidget,
    );
    expect(
      _valueOf(l10n.sessionSummaryNoTasks, l10n.sessionSummaryNone),
      findsOneWidget,
    );
    expect(find.text(l10n.sessionSummaryVerbal.toUpperCase()), findsNothing);
    await env.unmount();
  });

  testWidgets('нет такой сессии: сообщение с id и выход на дашборд', (
    tester,
  ) async {
    final env = await _pumpSummary(tester, id: 'abc-123');
    expect(find.text(l10n.sessionSummaryNotFound('abc-123')), findsOneWidget);
    await tester.tap(find.text(l10n.sessionSummaryToDashboard.toUpperCase()));
    await env.settle(8);
    expect(find.byType(DashboardScreen), findsOneWidget);
    await env.unmount();
  });

  testWidgets('320 px, шрифт ×1.5: итоги без overflow', (tester) async {
    final env = await _pumpSummary(
      tester,
      bundle: _fullBundle(),
      size: const Size(320, 640),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
    await env.unmount();
  });
}
