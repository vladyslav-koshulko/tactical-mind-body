import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/session/session_controller.dart';
import 'package:tmb_mobile/features/session/session_services.dart';
import 'package:tmb_mobile/features/session/session_state.dart';
import 'package:tmb_mobile/features/session/session_summary_screen.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../helpers.dart';
import 'session_kit.dart';

/// Жизненный цикл приложения и удержание когнитивного окна до срока
/// (ARCHITECTURE D14, D15).

Finder _phaseGlyph(TmbPhase phase) => find.byWidgetPredicate(
  (w) => w is TmbPhaseGlyph && w.phase == phase,
  description: 'TmbPhaseGlyph($phase)',
);

int _buttons(TmbButtonVariant variant) => find
    .byType(TmbButton)
    .evaluate()
    .where((e) => (e.widget as TmbButton).variant == variant)
    .length;

const _plank = Exercise(
  id: 'ex.test_plank',
  name: {'ru': 'Планка'},
  unit: ExerciseUnit.seconds,
  muscleGroups: [],
  inventory: [],
  locations: [Location.home],
);

/// Приложение уходит в фон на [ms] и возвращается. Пока оно скрыто, Flutter
/// кадры не рисует (`framesEnabled == false`), поэтому заглушка паузы видна
/// уже после возврата — как и на телефоне.
Future<void> _away(SessionEnv env, int ms) async {
  final binding = env.tester.binding;
  binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  env.now += ms;
  binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await env.settle(2);
}

Future<TaskAttempt> _onlyAttempt(WidgetTester tester, SessionEnv env) async {
  final id = (await tester.runAsync(env.sessions.listSessions))!.single.id;
  return (await tester.runAsync(() => env.sessions.attemptsOf(id)))!.single;
}

// --- контроллер без виджетов ----------------------------------------------------

final class _FakeLifecycle implements SessionLifecycleSource {
  void Function(AppLifecycleState)? _onChange;
  var listeners = 0;

  @override
  void Function() listen(void Function(AppLifecycleState state) onChange) {
    _onChange = onChange;
    listeners++;
    return () {
      _onChange = null;
      listeners--;
    };
  }

  void emit(AppLifecycleState state) => _onChange?.call(state);
}

final class _Clocks {
  int wall = fakeNowMs;
  int mono = 5000;
}

ProviderContainer _container(_Clocks clocks, _FakeLifecycle lifecycle) {
  final db = TmbDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: <Override>[
      databaseProvider.overrideWith((ref) {
        ref.onDispose(db.close);
        return db;
      }),
      clockProvider.overrideWithValue(() => clocks.wall),
      sessionMonotonicClockProvider.overrideWithValue(() => clocks.mono),
      sessionLifecycleProvider.overrideWithValue(lifecycle),
      contentProvider.overrideWith(
        (ref) async => const BuiltinContent(taskPacks: [], exercisePacks: []),
      ),
      exercisesProvider.overrideWith(
        (ref) async => const [exerciseA, exerciseB],
      ),
      taskSourcesProvider.overrideWith(
        (ref) async => [
          sourceOf(const [recallNumeric]),
        ],
      ),
      sessionSeedProvider.overrideWithValue(() => 7),
      sessionWakelockProvider.overrideWithValue(FakeWakelock()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

SessionRunning _running(ProviderContainer c) =>
    c.read(sessionControllerProvider).value! as SessionRunning;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('контроллер: пауза по жизненному циклу', () {
    late _Clocks clocks;
    late _FakeLifecycle lifecycle;
    late ProviderContainer container;
    late SessionController controller;

    /// Доводит сессию до когнитивной задачи (круг из двух подходов).
    Future<void> toCognitive() async {
      container.listen(sessionControllerProvider, (_, _) {});
      await container.read(sessionControllerProvider.future);
      controller = container.read(sessionControllerProvider.notifier);
      for (var i = 0; i < 2; i++) {
        clocks.mono += 2000;
        clocks.wall += 2000;
        controller.completeSet();
      }
      expect(_running(container).engine.phase, Phase.cognitive);
    }

    setUp(() {
      clocks = _Clocks();
      lifecycle = _FakeLifecycle();
      container = _container(clocks, lifecycle);
    });

    test('hidden и paused ставят на паузу, inactive и resumed — нет', () async {
      await toCognitive();
      lifecycle.emit(AppLifecycleState.inactive);
      expect(_running(container).isPaused, isFalse);
      lifecycle.emit(AppLifecycleState.hidden);
      expect(_running(container).isPaused, isTrue);
      // Возврат в приложение сам таймер не запускает: нужна кнопка.
      lifecycle.emit(AppLifecycleState.resumed);
      expect(_running(container).isPaused, isTrue);
      controller.resume();
      expect(_running(container).isPaused, isFalse);
      lifecycle.emit(AppLifecycleState.paused);
      expect(_running(container).isPaused, isTrue);
    });

    test(
      'latencyMs не включает паузу и не зависит от системных часов',
      () async {
        await toCognitive();
        clocks.mono += 3000;
        clocks.wall += 3000;
        lifecycle.emit(AppLifecycleState.hidden);

        // Час в фоне; системные часы при этом ещё и скачут назад.
        clocks.mono += 3600000;
        clocks.wall -= 86400000;
        controller.resume();
        final cognitive = _running(container).engine;
        expect(cognitive.phase, Phase.cognitive, reason: 'задача не истекла');
        expect(cognitive.stageRemainingMs, 20000 - 3000);

        clocks.mono += 4000;
        clocks.wall += 4000;
        controller.submitAnswer(TaskAnswer.recall('85'));
        final attempt = _running(container).engine.lastOutcome!.attempt;
        expect(attempt.status, AttemptStatus.answered);
        expect(attempt.latencyMs, 7000);
      },
    );

    test(
      'на паузе действия игнорируются, повтор паузы и resume — нет-оп',
      () async {
        await toCognitive();
        controller.resume(); // не на паузе
        expect(_running(container).isPaused, isFalse);
        lifecycle.emit(AppLifecycleState.hidden);
        lifecycle.emit(AppLifecycleState.paused); // повторная пауза
        clocks.mono += 1000;
        controller.submitAnswer(TaskAnswer.recall('85'));
        controller.skipTask();
        final st = _running(container);
        expect(st.isPaused, isTrue);
        expect(
          st.engine.lastOutcome,
          isNull,
          reason: 'ответ на паузе не принят',
        );
        expect(st.engine.stageRemainingMs, 20000);
      },
    );

    test('задача кончилась до окна: удержание, действия не проходят', () async {
      await toCognitive();
      clocks.mono += 3000;
      controller.submitAnswer(TaskAnswer.recall('85'));
      final st = _running(container);
      expect(st.hold, isNotNull);
      expect(st.hold!.totalMs, 180000);
      expect(st.hold!.remainingMs, 177000);
      expect(st.outcome, isNotNull, reason: 'итог задачи виден в удержании');
      expect(st.ratingOpen, isFalse);

      // Подходы следующего круга пока недоступны, как и «К итогам».
      controller.completeSet();
      controller.skipExercise();
      unawaitedFinish(controller);
      expect(_running(container).engine.exerciseIndex, 0);

      // Остаток считается по монотонным часам и замирает на паузе.
      clocks.mono += 10000;
      lifecycle.emit(AppLifecycleState.hidden);
      expect(_running(container).hold!.remainingMs, 167000);
      clocks.mono += 600000;
      controller.resume();
      expect(_running(container).hold!.remainingMs, 167000);
    });

    test(
      'подписка на жизненный цикл снимается вместе с контроллером',
      () async {
        await toCognitive();
        expect(lifecycle.listeners, 1);
        container.dispose();
        expect(lifecycle.listeners, 0);
      },
    );
  });

  group('экран: пауза при сворачивании', () {
    testWidgets('физика: заглушка, время стоит, «Продолжить» запускает дальше', (
      tester,
    ) async {
      final env = await pumpSession(
        tester,
        tasks: [recallNumeric],
        exercises: const [_plank],
      );
      await env.advance(10000);
      expect(find.text('00:20'), findsWidgets);

      // Десять минут в фоне: упражнение не завершилось само.
      await _away(env, 600000);
      final title = find.text(l10n.sessionPausedTitle.toUpperCase());
      expect(title, findsOneWidget);
      // Фаза читается без цвета: тот же квадрат и подпись; одна primary и одна
      // danger.
      expect(_phaseGlyph(TmbPhase.physical), findsWidgets);
      expect(find.text(l10n.phasePhysical.toUpperCase()), findsWidgets);
      expect(_buttons(TmbButtonVariant.primary), 1);
      expect(_buttons(TmbButtonVariant.danger), 1);
      expect(find.text('00:20'), findsNothing, reason: 'таймер скрыт');

      expect(title, findsOneWidget, reason: 'возврат сам не продолжает');
      await env.tapText(l10n.sessionResume);
      expect(title, findsNothing);
      expect(find.text('00:20'), findsWidgets);
      expect(_phaseGlyph(TmbPhase.physical), findsWidgets);

      await env.advance(5000);
      expect(find.text('00:15'), findsWidgets);
      await env.unmount();
    });

    testWidgets('когниция: латентность без паузы, задача скрыта, ввод цел', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      await env.advance(3000);
      await env.tapDigits('8');

      await _away(env, 300000); // пять минут: без паузы это таймаут
      expect(find.text(l10n.sessionPausedTitle.toUpperCase()), findsOneWidget);
      expect(_phaseGlyph(TmbPhase.cognitive), findsWidgets);
      expect(find.text(l10n.phaseCognitive.toUpperCase()), findsWidgets);
      expect(
        find.text('Сколько будет 47 + 38?'),
        findsNothing,
        reason: 'условие не видно, пока таймер стоит',
      );
      await env.tapText(l10n.sessionResume);

      expect(find.text('Сколько будет 47 + 38?'), findsOneWidget);
      expect(find.text('8'), findsWidgets, reason: 'введённое сохранилось');
      await env.advance(4000);
      await env.tapDigits('5');
      await env.tapText(l10n.sessionAnswerSubmit);

      final a = await _onlyAttempt(tester, env);
      expect(a.status, AttemptStatus.answered);
      expect(a.isCorrect, isTrue);
      expect(a.latencyMs, 7000);
      await env.unmount();
    });

    testWidgets('inactive (шторка, диалог) не прерывает сессию', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await env.settle(1);
      expect(find.text(l10n.sessionPausedTitle.toUpperCase()), findsNothing);
      await env.unmount();
    });

    testWidgets('из паузы можно эвакуироваться', (tester) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound(sets: 1);
      await _away(env, 1000);
      await env.tapText(l10n.sessionEvacuate);
      await env.tapText(l10n.sessionEvacuateConfirm);
      await env.settle(8);
      expect(find.byType(SessionSummaryScreen), findsOneWidget);
      final s = (await tester.runAsync(env.sessions.listSessions))!.single;
      expect(s.endedAt, isNull);
      await env.unmount();
    });

    testWidgets('на оценке последнего круга паузить нечего', (tester) async {
      final env = await pumpSession(
        tester,
        tasks: [recallNumeric],
        prefs: const SessionPreferences(
          template: SessionTemplateKind.physicalOnly,
          rounds: 1,
        ),
      );
      await env.completeRound();
      expect(find.text(l10n.sessionFinishedTitle.toUpperCase()), findsWidgets);
      await _away(env, 1000);
      expect(find.text(l10n.sessionPausedTitle.toUpperCase()), findsNothing);
      await env.unmount();
    });
  });

  group('экран: окно держится до срока (D15)', () {
    testWidgets('остаток паузы, заблокированная кнопка, переход по таймеру', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      await env.advance(2000);
      await env.tapDigits('85');
      await env.tapText(l10n.sessionAnswerSubmit);

      // Окно 180 с, ушло 2: на экране остаток, оранжевая фаза и два канала.
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.sessionHoldBody), findsOneWidget);
      expect(_phaseGlyph(TmbPhase.cognitive), findsWidgets);
      expect(find.byType(TmbRadarTimer), findsOneWidget);
      expect(find.text('02:58'), findsWidgets);
      final next = tester.widget<TmbButton>(
        find.widgetWithText(TmbButton, l10n.sessionHoldNext.toUpperCase()),
      );
      expect(next.onPressed, isNull, reason: 'кнопка заблокирована до срока');
      expect(_buttons(TmbButtonVariant.danger), 1);

      await env.advance(100000);
      expect(find.text('01:18'), findsWidgets);
      await env.advance(77000);
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsOneWidget);
      await env.advance(1000);
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsNothing);
      expect(_phaseGlyph(TmbPhase.physical), findsWidgets);
      await env.unmount();
    });

    testWidgets('пауза приложения внутри удержания не съедает остаток', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      await env.advance(2000);
      await env.tapDigits('85');
      await env.tapText(l10n.sessionAnswerSubmit);

      await env.advance(50000);
      await _away(env, 1200000); // двадцать минут в фоне
      await env.tapText(l10n.sessionResume);
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsOneWidget);
      expect(find.text('02:08'), findsWidgets); // 180 − 2 − 50

      await env.advance(127000);
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsOneWidget);
      await env.advance(1000);
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsNothing);
      expect(_phaseGlyph(TmbPhase.physical), findsWidgets);
      await env.unmount();
    });

    testWidgets('последнее окно: итоги по сроку, endedAt включает окно', (
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
      final startedAt = env.now;
      await env.advance(3000);
      await env.tapDigits('85');
      await env.tapText(l10n.sessionAnswerSubmit);
      expect(find.text(l10n.sessionHoldTitle.toUpperCase()), findsOneWidget);
      expect(
        find.text(l10n.sessionToSummary.toUpperCase()),
        findsOneWidget,
        reason: 'следующего этапа нет: заблокированная кнопка ведёт к итогам',
      );
      await env.advance(177000);
      await env.settle(8);
      expect(find.byType(SessionSummaryScreen), findsOneWidget);
      final s = (await tester.runAsync(env.sessions.listSessions))!.single;
      expect(s.endedAt! - s.startedAt, 180000);
      expect(s.startedAt, startedAt);
      await env.unmount();
    });

    testWidgets('эвакуация из удержания посреди сессии — прерывание', (
      tester,
    ) async {
      final env = await pumpSession(tester, tasks: [recallNumeric]);
      await env.completeRound();
      await env.advance(2000);
      await env.tapDigits('85');
      await env.tapText(l10n.sessionAnswerSubmit);
      await env.tapText(l10n.sessionEvacuate);
      await env.tapText(l10n.sessionEvacuateConfirm);
      await env.settle(8);
      expect(find.byType(SessionSummaryScreen), findsOneWidget);
      final s = (await tester.runAsync(env.sessions.listSessions))!.single;
      expect(s.endedAt, isNull);
      await env.unmount();
    });
  });
}

/// `finish` асинхронный и тут должен быть нет-опом; результат не важен.
void unawaitedFinish(SessionController controller) {
  controller.finish();
}
