import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/dashboard/dashboard_screen.dart';
import 'package:tmb_mobile/features/session/session_screen.dart';
import 'package:tmb_mobile/features/session/session_summary_screen.dart';
import 'package:tmb_mobile/features/session/task_views.dart';
import 'package:tmb_mobile/l10n/app_localizations_uk.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'session_kit.dart';

final _hex64 = RegExp(r'^[0-9a-f]{64}$');

Finder _phaseGlyph(TmbPhase phase) => find.byWidgetPredicate(
  (w) => w is TmbPhaseGlyph && w.phase == phase,
  description: 'TmbPhaseGlyph($phase)',
);

int _buttons(TmbButtonVariant variant) => find
    .byType(TmbButton)
    .evaluate()
    .where((e) => (e.widget as TmbButton).variant == variant)
    .length;

void main() {
  group('полный проход', () {
    testWidgets(
      'физика → пауза с числовым ответом → оценка круга → итоги, события в БД',
      (tester) async {
        final env = await pumpSession(tester, tasks: [recallNumeric]);

        // Экран 02: радар, список круга, одна primary и одна danger.
        expect(find.byType(SessionScreen), findsOneWidget);
        expect(find.byType(TmbRadarTimer), findsOneWidget);
        expect(find.byType(TmbRoundList), findsOneWidget);
        expect(find.text('ОТЖИМАНИЯ'), findsOneWidget);
        expect(_buttons(TmbButtonVariant.primary), 1);
        expect(_buttons(TmbButtonVariant.danger), 1);
        // Фаза читается без цвета: квадрат и подпись.
        expect(_phaseGlyph(TmbPhase.physical), findsWidgets);
        expect(find.text(l10n.phasePhysical.toUpperCase()), findsWidgets);
        expect(env.wakelock.enabled, isTrue);

        // Сессия уже в БД, пока ничего не сделано.
        final started = (await tester.runAsync(env.sessions.listSessions))!;
        expect(started, hasLength(1));
        expect(started.single.endedAt, isNull);
        final id = started.single.id;

        await env.completeRound();

        // Экран 03: весь экран в когнитивной фазе, ромб и подпись, вибро.
        expect(_phaseGlyph(TmbPhase.cognitive), findsWidgets);
        expect(_phaseGlyph(TmbPhase.physical), findsNothing);
        expect(find.text(l10n.phaseCognitive.toUpperCase()), findsWidgets);
        expect(find.text('Сколько будет 47 + 38?'), findsOneWidget);
        expect(find.byType(TmbNumericKeypad), findsOneWidget);
        expect(env.haptics, contains('HapticFeedbackType.heavyImpact'));
        expect(_buttons(TmbButtonVariant.danger), 1);

        await env.advance(7000);
        await env.tapDigits('85');
        expect(find.text('85'), findsWidgets);
        await env.tapText(l10n.sessionAnswerSubmit);

        // Попытка уже в БД, хотя сессия ещё идёт (ARCHITECTURE D9).
        final attempts = (await tester.runAsync(
          () => env.sessions.attemptsOf(id),
        ))!;
        expect(attempts, hasLength(1));
        final a = attempts.single;
        expect(a.status, AttemptStatus.answered);
        expect(a.isCorrect, isTrue);
        expect(a.response, '85');
        expect(a.latencyMs, 7000);
        expect(a.taskId, recallNumeric.id);
        expect(a.payloadHash, matches(_hex64));
        expect(a.archetype, TaskArchetype.recall);
        expect(a.roundIndex, 0);
        expect(a.packSource, PackSource.builtin);

        // Круг 2: баннер итога задачи, карточка оценки прошлого круга.
        expect(_phaseGlyph(TmbPhase.physical), findsWidgets);
        expect(
          find.text(l10n.sessionOutcomeCorrect.toUpperCase()),
          findsOneWidget,
        );
        expect(
          find.text(l10n.sessionRatingTitle.toUpperCase()),
          findsOneWidget,
        );
        await env.tapText(l10n.sessionEffortHard);
        expect(
          find.text(l10n.sessionRatingSaved(l10n.sessionEffortHard)),
          findsOneWidget,
        );

        // Круг 1 ещё ждёт оценки — в БД его нет; первый подход круга 2 закрывает окно.
        expect(
          (await tester.runAsync(() => env.sessions.roundsOf(id)))!,
          isEmpty,
        );
        await env.advance(2000);
        await env.tapText(l10n.sessionSetDone);
        final rounds = (await tester.runAsync(
          () => env.sessions.roundsOf(id),
        ))!;
        expect(rounds, hasLength(1));
        expect(rounds.single.rpe, 3);
        // Подходы идущего круга ждут его закрытия (FK на `RoundLog`).
        expect(
          (await tester.runAsync(() => env.sessions.setsOf(id)))!,
          hasLength(2),
        );

        await env.advance(2000);
        await env.tapText(l10n.sessionSetDone);

        // Последний круг: экран оценки перед итогами.
        expect(
          find.text(l10n.sessionFinishedTitle.toUpperCase()),
          findsOneWidget,
        );
        expect(find.byType(SessionSummaryScreen), findsNothing);
        await env.tapText(l10n.sessionEffortNormal);
        await env.tapText(l10n.sessionToSummary);
        await env.settle(8);

        // Итоги.
        expect(find.byType(SessionSummaryScreen), findsOneWidget);
        expect(env.currentSessionId, id);
        expect(env.wakelock.enabled, isFalse);
        expect(
          find.text(l10n.sessionSummaryTitle.toUpperCase()),
          findsOneWidget,
        );
        expect(
          find.text(l10n.sessionSummaryStatusCompleted.toUpperCase()),
          findsOneWidget,
        );
        expect(find.text('00:15'), findsOneWidget); // длительность
        expect(find.text(l10n.sessionSummaryOutOf(4, 4)), findsOneWidget);
        expect(find.text(l10n.sessionSummaryFactPlan(60, 60)), findsOneWidget);
        expect(
          find.text(l10n.sessionSummarySecondsValue('7.0')),
          findsOneWidget,
        );

        // В БД: сессия закрыта, два круга с оценкой, четыре подхода.
        final session = (await tester.runAsync(
          () => env.sessions.getSession(id),
        ))!;
        expect(session.endedAt, env.now);
        final bundle = (await tester.runAsync(
          () => env.sessions.loadSession(id),
        ))!;
        expect(bundle.rounds.map((r) => r.rpe), [3, 2]);
        expect(bundle.sets, hasLength(4));
        expect(bundle.sets.every((s) => s.done == defaultReps), isTrue);

        await tester.tap(
          find.text(l10n.sessionSummaryToDashboard.toUpperCase()),
        );
        await env.settle(8);
        expect(find.byType(DashboardScreen), findsOneWidget);
        await env.unmount();
      },
    );

    testWidgets('«подход выполнен» с вводом фактического числа', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.advance(1000);

      await env.tapText(l10n.sessionSetCustom);
      expect(find.text(l10n.sessionActualTitle.toUpperCase()), findsOneWidget);
      // Предзаполнено предписанным; первая цифра заменяет его.
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('$defaultReps ${l10n.sessionUnitReps}'),
        ),
        findsOneWidget,
      );
      await env.tapDigits('12');
      await env.tapText(l10n.sessionActualConfirm);

      final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;
      await env.completeRound(sets: 1);
      await env.tapText(l10n.sessionEvacuate);
      await env.tapText(l10n.sessionEvacuateConfirm);
      await env.settle(8);
      final sets = (await tester.runAsync(() => env.sessions.setsOf(id)))!;
      expect(sets.map((s) => (s.prescribed, s.done)), [
        (defaultReps, 12),
        (defaultReps, defaultReps),
      ]);
    });

    testWidgets('«пропустить упражнение» пишет подход с done = 0', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.advance(1000);
      await env.tapText(l10n.sessionSkipExercise);
      final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;
      await env.tapText(l10n.sessionEvacuate);
      await env.tapText(l10n.sessionEvacuateConfirm);
      await env.settle(8);
      final sets = (await tester.runAsync(() => env.sessions.setsOf(id)))!;
      expect(sets.single.done, 0);
      expect(sets.single.prescribed, defaultReps);
    });

    testWidgets(
      'упражнение в секундах: радар отсчитывает и завершает по сроку',
      (tester) async {
        const plank = Exercise(
          id: 'ex.test_plank',
          name: {'ru': 'Планка'},
          unit: ExerciseUnit.seconds,
          muscleGroups: [],
          inventory: [],
          locations: [Location.home],
        );
        final env = await pumpSession(
          tester,
          tasks: [recallNumeric],
          exercises: const [plank],
        );
        expect(find.text('00:30'), findsWidgets);
        await env.advance(10000);
        expect(find.text('00:20'), findsWidgets);

        await env.advance(21000); // срок вышел — упражнение завершилось само
        expect(_phaseGlyph(TmbPhase.cognitive), findsWidgets);
        final id = (await tester.runAsync(env.sessions.listSessions))!
            .single
            .id;
        await env.tapText(l10n.sessionEvacuate);
        await env.tapText(l10n.sessionEvacuateConfirm);
        await env.settle(8);
        final sets = (await tester.runAsync(() => env.sessions.setsOf(id)))!;
        expect(sets.single.unit, ExerciseUnit.seconds);
        expect(sets.single.done, 30);
      },
    );

    testWidgets('physical_only с отдыхом: экран отдыха и оценка круга', (
      tester,
    ) async {
      final env = await pumpSession(
        tester,
        tasks: [recallNumeric],
        prefs: const SessionPreferences(
          template: SessionTemplateKind.physicalOnly,
          rounds: 2,
          restSec: 30,
        ),
      );
      await env.completeRound();
      expect(find.text(l10n.sessionRestPhase.toUpperCase()), findsWidgets);
      expect(find.text(l10n.sessionRatingTitle.toUpperCase()), findsOneWidget);
      expect(find.text('00:30'), findsWidgets);
      await env.advance(31000);
      expect(find.text(l10n.sessionRestPhase.toUpperCase()), findsNothing);
      expect(find.text(l10n.sessionSetDone.toUpperCase()), findsOneWidget);
    });

    testWidgets('cognitive_only: оценивать нечего — сразу итоги', (
      tester,
    ) async {
      final env = await pumpSession(
        tester,
        tasks: [recallNumeric],
        prefs: const SessionPreferences(
          template: SessionTemplateKind.cognitiveOnly,
          rounds: 1,
        ),
      );
      expect(_phaseGlyph(TmbPhase.cognitive), findsWidgets);
      await env.advance(3000);
      await env.tapDigits('85');
      await env.tapText(l10n.sessionAnswerSubmit);
      await env.settle(8);
      expect(find.byType(SessionSummaryScreen), findsOneWidget);
      expect(find.text(l10n.sessionSummaryOutOf(0, 0)), findsNothing);
      final s = (await tester.runAsync(env.sessions.listSessions))!.single;
      expect(s.endedAt, isNotNull);
    });
  });

  group('эвакуация', () {
    testWidgets('подтверждение; отмена продолжает, подтверждение — в итоги', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound(sets: 1);
      final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;

      await env.tapText(l10n.sessionEvacuate);
      expect(
        find.text(l10n.sessionEvacuateTitle.toUpperCase()),
        findsOneWidget,
      );
      // Ничего не прервано, пока не подтверждено.
      await env.tapText(l10n.sessionEvacuateCancel);
      expect(find.text(l10n.sessionEvacuateTitle.toUpperCase()), findsNothing);
      expect(find.byType(SessionScreen), findsOneWidget);

      await env.tapText(l10n.sessionEvacuate);
      await env.tapText(l10n.sessionEvacuateConfirm);
      await env.settle(8);

      expect(find.byType(SessionSummaryScreen), findsOneWidget);
      expect(
        find.text(l10n.sessionSummaryStatusAborted.toUpperCase()),
        findsOneWidget,
      );
      expect(env.currentSessionId, id);

      // Прерванная: endedAt = null (решение 32), сделанное сохранено.
      final bundle = (await tester.runAsync(
        () => env.sessions.loadSession(id),
      ))!;
      expect(bundle.session.endedAt, isNull);
      expect(bundle.sets, hasLength(1));
      expect(bundle.rounds, hasLength(1));
      expect(bundle.rounds.single.rpe, isNull);
      expect(env.wakelock.enabled, isFalse);
    });

    testWidgets('системное «назад» спрашивает подтверждение', (tester) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await tester.binding.handlePopRoute();
      await env.settle();
      expect(
        find.text(l10n.sessionEvacuateTitle.toUpperCase()),
        findsOneWidget,
      );
      await env.tapText(l10n.sessionEvacuateCancel);
      expect(find.byType(SessionScreen), findsOneWidget);
    });

    testWidgets(
      'эвакуация посреди когнитивной паузы: задача без ответа не пишется',
      (tester) async {
        final env = await pumpSession(tester, tasks: [recallNumeric]);
        await env.completeRound();
        final id = (await tester.runAsync(env.sessions.listSessions))!
            .single
            .id;
        await env.advance(3000);
        await env.tapText(l10n.sessionEvacuate);
        await env.tapText(l10n.sessionEvacuateConfirm);
        await env.settle(8);
        final bundle = (await tester.runAsync(
          () => env.sessions.loadSession(id),
        ))!;
        expect(bundle.attempts, isEmpty);
        expect(bundle.rounds, hasLength(1));
        expect(bundle.sets, hasLength(2));
      },
    );
  });

  group('таймаут и пропуск задачи', () {
    testWidgets('таймаут: запись timeout, баннер, следующий круг', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;

      await env.advance(21000); // timeSec = 20
      expect(
        find.text(l10n.sessionOutcomeTimeout.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(l10n.sessionOutcomeReveal('47 + 38 = 85.')),
        findsOneWidget,
      );
      expect(_phaseGlyph(TmbPhase.physical), findsWidgets);

      final a = (await tester.runAsync(() => env.sessions.attemptsOf(id)))!
          .single;
      expect(a.status, AttemptStatus.timeout);
      expect(a.isCorrect, isFalse);
      expect(a.latencyMs, isNull);
      expect(a.response, isNull);
      expect(a.payloadHash, matches(_hex64));

      // Баннер не висит вечно.
      await env.advance(5000);
      expect(find.text(l10n.sessionOutcomeTimeout.toUpperCase()), findsNothing);
    });

    testWidgets('пропуск задачи: skipped, isCorrect = false', (tester) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;
      await env.advance(2000);
      await env.tapText(l10n.sessionTaskSkip);
      expect(
        find.text(l10n.sessionOutcomeSkipped.toUpperCase()),
        findsOneWidget,
      );
      final a = (await tester.runAsync(() => env.sessions.attemptsOf(id)))!
          .single;
      expect(a.status, AttemptStatus.skipped);
      expect(a.isCorrect, isFalse);
    });
  });

  group('архетипы', () {
    Future<TaskAttempt> only(WidgetTester tester, SessionEnv env) async {
      final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;
      return (await tester.runAsync(() => env.sessions.attemptsOf(id)))!.first;
    }

    testWidgets('recall: минус и запятая; неверный ответ → isCorrect = false', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      await env.tapDigits('8,5');
      await env.tapDigits('-');
      expect(find.text('-8,5'), findsOneWidget);
      await env.tapText(l10n.sessionAnswerSubmit);
      final a = await only(tester, env);
      expect(a.response, '-8,5');
      expect(a.isCorrect, isFalse);
    });

    testWidgets('recall с текстовым ответом: поле, а не цифровая клавиатура', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallText]);
      await env.completeRound();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(TmbNumericKeypad), findsNothing);
      await env.advance(2000);
      await tester.enterText(find.byType(TextField), '  Купол ');
      await env.settle(1);
      await env.tapText(l10n.sessionAnswerSubmit);
      final a = await only(tester, env);
      expect(a.response, 'Купол');
      expect(a.isCorrect, isTrue);
    });

    testWidgets(
      'choice: ответ пишется по исходному порядку, не по показанному',
      (tester) async {
        final env = await pumpSession(tester, tasks: [choiceTask]);
        await env.completeRound();
        expect(find.byType(TmbChoiceTile), findsNWidgets(3));
        // Пока ничего не выбрано — «Ответить» недоступно.
        TmbButton submit() => tester.widget<TmbButton>(
          find.widgetWithText(
            TmbButton,
            l10n.sessionAnswerSubmit.toUpperCase(),
          ),
        );
        expect(submit().onPressed, isNull);
        await env.advance(2500);
        await env.tapText('Браво', upper: false);
        expect(submit().onPressed, isNotNull);
        await env.tapText(l10n.sessionAnswerSubmit);
        final a = await only(tester, env);
        expect(a.archetype, TaskArchetype.choice);
        expect(a.response, '1');
        expect(a.isCorrect, isTrue);
        expect(a.latencyMs, 2500);
      },
    );

    testWidgets('ordering: шаги нажимаются по порядку, ответ — индексы', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [orderingTask]);
      await env.completeRound();
      for (final step in orderingTask.items) {
        await env.tapText(step, upper: false);
      }
      expect(find.text('1. Первый шаг'), findsOneWidget);
      expect(find.text('3. Третий шаг'), findsOneWidget);
      await env.tapText(l10n.sessionAnswerSubmit);
      final a = await only(tester, env);
      expect(a.response, '0,1,2');
      expect(a.isCorrect, isTrue);
    });

    testWidgets('spatial: показ сетки, затем ответ нажатием клетки', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [spatialTask]);
      await env.completeRound();

      // Стадия показа: подписи на сетке, вопрос скрыт.
      expect(find.byType(SpatialGridView), findsOneWidget);
      expect(find.text('Б'), findsOneWidget);
      expect(find.text(spatialTask.prompt), findsNothing);
      await env.advance(1000);
      await env.tapText(l10n.sessionStudyDone);

      // Стадия ответа: подписей нет, вопрос виден.
      expect(find.text('Б'), findsNothing);
      expect(find.text(spatialTask.prompt), findsOneWidget);
      final cells = find.descendant(
        of: find.byType(SpatialGridView),
        matching: find.byType(GestureDetector),
      );
      expect(cells, findsNWidgets(9));
      await tester.tap(cells.at(1 * 3 + 2)); // ряд 1, столбец 2
      await env.settle(1);
      await env.advance(1500);
      await env.tapText(l10n.sessionAnswerSubmit);
      final a = await only(tester, env);
      expect(a.response, '1,2');
      expect(a.isCorrect, isTrue);
      expect(a.latencyMs, 1500); // время считается от конца показа
    });

    testWidgets(
      'delayed_recall: запоминание сейчас, вопрос в следующей паузе',
      (tester) async {
        final env = await pumpSession(
          tester,
          tasks: [delayedTask],
          prefs: const SessionPreferences(rounds: 3),
        );
        await env.completeRound();
        expect(find.text('Пост номер три'), findsOneWidget);
        expect(find.byType(TmbNumericKeypad), findsNothing);
        await env.tapText(l10n.sessionStudyDone);
        // Запоминание попытки не пишет.
        final id = (await tester.runAsync(env.sessions.listSessions))!
            .single
            .id;
        expect(
          (await tester.runAsync(() => env.sessions.attemptsOf(id)))!,
          isEmpty,
        );

        await env.completeRound();
        expect(find.text('Какой был номер поста?'), findsOneWidget);
        expect(find.text('Пост номер три'), findsNothing);
        await env.advance(4000);
        await env.tapDigits('3');
        await env.tapText(l10n.sessionAnswerSubmit);
        final a = await only(tester, env);
        expect(a.archetype, TaskArchetype.delayedRecall);
        expect(a.isCorrect, isTrue);
        expect(a.encodedRoundIndex, 0);
        expect(a.roundIndex, 1);
      },
    );

    testWidgets(
      'verbal: речь, смена условия, самопроверка → isCorrect null и selfRating',
      (tester) async {
        final env = await pumpSession(tester, tasks: [verbalTask]);
        await env.completeRound();
        expect(find.text(verbalTask.prompt), findsOneWidget);
        expect(
          find.text(l10n.sessionVerbalSpeak.toUpperCase()),
          findsOneWidget,
        );
        expect(find.text(l10n.sessionCueTitle.toUpperCase()), findsNothing);

        // Смена условия посреди задачи: заметна текстом и иконкой, плюс вибро.
        await env.advance(3500);
        expect(find.text(l10n.sessionCueTitle.toUpperCase()), findsOneWidget);
        expect(find.text('Теперь без слов на букву А'), findsOneWidget);
        expect(find.byIcon(Icons.priority_high), findsOneWidget);
        expect(env.haptics, contains('HapticFeedbackType.mediumImpact'));

        await env.advance(4000);
        await env.tapText(l10n.sessionVerbalFinish);
        expect(
          find.text(l10n.sessionVerbalSelfCheckTitle.toUpperCase()),
          findsOneWidget,
        );
        expect(find.text(l10n.sessionYes.toUpperCase()), findsNWidgets(3));
        TmbButton submit() => tester.widget<TmbButton>(
          find.widgetWithText(
            TmbButton,
            l10n.sessionAnswerSubmit.toUpperCase(),
          ),
        );
        expect(submit().onPressed, isNull);

        final yes = find.text(l10n.sessionYes.toUpperCase());
        final no = find.text(l10n.sessionNo.toUpperCase());
        for (final f in [yes.at(0), yes.at(1), no.at(2)]) {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await env.settle(1);
        }
        expect(submit().onPressed, isNotNull);
        await env.tapText(l10n.sessionAnswerSubmit);

        final a = await only(tester, env);
        expect(a.archetype, TaskArchetype.verbal);
        expect(a.status, AttemptStatus.answered);
        expect(a.isCorrect, isNull); // машина не оценивает (инвариант 7)
        expect(a.selfRating, 2); // 2 «да» из 3
        expect(a.response, isNull);
        expect(a.latencyMs, isNotNull);
      },
    );

    testWidgets('verbal: время речи вышло — сразу самопроверка', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [verbalTask]);
      await env.completeRound();
      await env.advance(31000); // timeSec = 30
      expect(
        find.text(l10n.sessionVerbalSelfCheckTitle.toUpperCase()),
        findsOneWidget,
      );
      // Само время не завершает задачу: ответ даёт человек.
      expect(find.text(l10n.sessionYes.toUpperCase()), findsNWidgets(3));
    });
  });

  testWidgets('украинская локаль: экраны сессии на украинском', (tester) async {
    final uk = AppLocalizationsUk();
    final env = await pumpSession(
      tester,
      tasks: [recallNumeric],
      locale: const Locale('uk'),
    );
    expect(find.text(uk.sessionSetDone.toUpperCase()), findsOneWidget);
    expect(find.text(uk.sessionRoundTitle(1, 2).toUpperCase()), findsOneWidget);
    expect(find.text(uk.sessionEvacuate.toUpperCase()), findsOneWidget);
    await env.completeRound(label: uk.sessionSetDone);
    expect(find.text(uk.sessionTaskTitle(1, 1).toUpperCase()), findsOneWidget);
    expect(find.text(uk.phaseCognitive.toUpperCase()), findsWidgets);
    expect(find.text(uk.sessionAnswerSubmit.toUpperCase()), findsOneWidget);
    await env.unmount();
  });

  testWidgets('смена фазы вибрирует каждый раз', (tester) async {
    final env = await pumpSession(tester, tasks: [recallNumeric]);
    expect(env.haptics, isEmpty); // старт — не смена
    await env.completeRound();
    expect(env.haptics, hasLength(1)); // физика → пауза
    await env.advance(21000);
    expect(env.haptics, hasLength(2)); // пауза → физика
    expect(env.haptics.toSet(), {'HapticFeedbackType.heavyImpact'});
  });

  testWidgets('нет подходящего пула: понятная ошибка вместо экрана сессии', (
    tester,
  ) async {
    final env = await pumpSession(
      tester,
      tasks: [recallNumeric],
      exercises: const [], // для места «Дом» нет упражнений
    );
    expect(find.text(l10n.sessionErrorTitle.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.sessionErrorNoExercises), findsOneWidget);
    expect(_buttons(TmbButtonVariant.primary), 1);
    expect(env.wakelock.enableCalls, 0);
    await tester.tap(find.text(l10n.sessionBackToDashboard.toUpperCase()));
    await env.settle(8);
    expect(env.router.state.uri.path, TmbRoutes.home);
    await env.unmount();
  });
}
