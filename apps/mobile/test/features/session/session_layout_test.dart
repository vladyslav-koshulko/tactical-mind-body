import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/features/session/task_views.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'session_kit.dart';

/// Самый тесный случай: ширина 320 и системный шрифт ×1.5. Любой overflow
/// кладёт тест (flutter_test ловит его как исключение рендера).
const _narrow = Size(320, 640);
const _scale = 1.5;

Future<SessionEnv> _pump(
  WidgetTester tester,
  List<CognitiveTask> tasks, {
  SessionPreferences prefs = const SessionPreferences(rounds: 2),
}) => pumpSession(
  tester,
  tasks: tasks,
  prefs: prefs,
  size: _narrow,
  textScale: _scale,
);

void _noOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

/// Все действия экрана доступны: кнопки внутри экрана и достаточно крупные.
void _tapTargetsOk(WidgetTester tester) {
  for (final e in find.byType(TmbButton).evaluate()) {
    final size = tester.getSize(find.byWidget(e.widget));
    expect(size.height, greaterThanOrEqualTo(TmbSize.tapTarget));
  }
}

/// «Эвакуация» видна без прокрутки: целиком внутри видимой области (экран
/// минус системная клавиатура) и не лежит внутри прокручиваемого контейнера.
void _evacuateAlwaysVisible(WidgetTester tester, Size size, {double ime = 0}) {
  final finder = find.text(l10n.sessionEvacuate.toUpperCase());
  expect(finder, findsOneWidget);
  expect(
    find.ancestor(of: finder, matching: find.byType(Scrollable)),
    findsNothing,
    reason: 'Эвакуация не должна быть внутри прокручиваемой области',
  );
  final button = find.ancestor(of: finder, matching: find.byType(TmbButton));
  final rect = tester.getRect(button);
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.bottom, lessThanOrEqualTo(size.height - ime));
  expect(rect.height, greaterThanOrEqualTo(TmbSize.tapTarget));
}

void main() {
  group('Эвакуация видна без прокрутки в когнитивной фазе', () {
    const sizes = {
      '360×800 ×1': (Size(360, 800), 1.0),
      '360×800 ×1.5': (Size(360, 800), 1.5),
      '320×568 ×1.5': (Size(320, 568), 1.5),
    };
    final tasks = {
      'recall (цифры, клавиатура)': recallNumeric,
      'recall (текст)': recallText,
      'choice': choiceTask,
      'verbal': verbalTask,
    };
    for (final MapEntry(key: sizeName, value: (size, scale)) in sizes.entries) {
      for (final MapEntry(key: taskName, value: task) in tasks.entries) {
        testWidgets('$taskName, $sizeName', (tester) async {
          final env = await pumpSession(
            tester,
            tasks: [task],
            prefs: const SessionPreferences(rounds: 2),
            size: size,
            textScale: scale,
          );
          // Физический экран: то же требование.
          _evacuateAlwaysVisible(tester, size);
          await env.completeRound();
          expect(find.text(l10n.phaseCognitive.toUpperCase()), findsWidgets);
          _noOverflow(tester);
          _evacuateAlwaysVisible(tester, size);
          await env.unmount();
        });
      }
    }

    testWidgets(
      'recall (текст) с открытой системной клавиатурой, 320×568 ×1.5',
      (tester) async {
        const size = Size(320, 568);
        final env = await pumpSession(
          tester,
          tasks: [recallText],
          size: size,
          textScale: 1.5,
        );
        await env.completeRound();
        const ime = 250.0;
        tester.view.viewInsets = const FakeViewPadding(bottom: ime * 3);
        addTearDown(tester.view.resetViewInsets);
        await env.settle();
        _noOverflow(tester);
        _evacuateAlwaysVisible(tester, size, ime: ime);
        await env.unmount();
      },
    );
  });

  group('320 px, шрифт ×1.5: нет overflow', () {
    testWidgets('физическая фаза', (tester) async {
      final env = await _pump(tester, [recallNumeric]);
      _noOverflow(tester);
      _tapTargetsOk(tester);
      expect(find.byType(TmbRadarTimer), findsOneWidget);
      await env.unmount();
    });

    testWidgets('физическая фаза: окно оценки круга открыто', (tester) async {
      final env = await _pump(tester, [recallNumeric]);
      await env.completeRound();
      await env.advance(21000); // таймаут → окно держится до срока
      await env.advance(159000); // срок → круг 2 с карточкой оценки
      expect(find.text(l10n.sessionRatingTitle.toUpperCase()), findsOneWidget);
      _noOverflow(tester);
      _tapTargetsOk(tester);
      await env.unmount();
    });

    testWidgets('шторка ввода фактического числа', (tester) async {
      final env = await _pump(tester, [recallNumeric]);
      await env.tapText(l10n.sessionSetCustom);
      _noOverflow(tester);
      expect(find.byType(TmbNumericKeypad), findsOneWidget);
      await env.unmount();
    });

    testWidgets('диалог эвакуации', (tester) async {
      final env = await _pump(tester, [recallNumeric]);
      await env.tapText(l10n.sessionEvacuate);
      _noOverflow(tester);
      expect(
        find.text(l10n.sessionEvacuateTitle.toUpperCase()),
        findsOneWidget,
      );
      await env.unmount();
    });

    testWidgets('отдых', (tester) async {
      final env = await _pump(
        tester,
        [recallNumeric],
        prefs: const SessionPreferences(
          template: SessionTemplateKind.physicalOnly,
          rounds: 2,
          restSec: 30,
        ),
      );
      await env.completeRound();
      _noOverflow(tester);
      await env.unmount();
    });

    testWidgets('экран оценки последнего круга', (tester) async {
      final env = await _pump(
        tester,
        [recallNumeric],
        prefs: const SessionPreferences(
          template: SessionTemplateKind.physicalOnly,
          rounds: 1,
        ),
      );
      await env.completeRound();
      expect(
        find.text(l10n.sessionFinishedTitle.toUpperCase()),
        findsOneWidget,
      );
      _noOverflow(tester);
      await env.unmount();
    });

    void archetype(
      String name,
      CognitiveTask task, {
      Future<void> Function(WidgetTester, SessionEnv)? then,
      Finder Function()? expects,
    }) {
      testWidgets('пауза: $name', (tester) async {
        final env = await _pump(tester, [task]);
        await env.completeRound();
        expect(find.text(l10n.phaseCognitive.toUpperCase()), findsWidgets);
        _noOverflow(tester);
        _tapTargetsOk(tester);
        if (expects != null) expect(expects(), findsWidgets);
        if (then != null) {
          await then(tester, env);
          _noOverflow(tester);
          _tapTargetsOk(tester);
        }
        await env.unmount();
      });
    }

    archetype(
      'recall (цифры)',
      recallNumeric,
      expects: () => find.byType(TmbNumericKeypad),
      then: (tester, env) => env.tapDigits('85'),
    );
    archetype(
      'recall (текст)',
      recallText,
      expects: () => find.byType(TextField),
    );
    archetype(
      'choice',
      choiceTask,
      expects: () => find.byType(TmbChoiceTile),
      then: (tester, env) => env.tapText('Альфа', upper: false),
    );
    archetype(
      'ordering',
      orderingTask,
      expects: () => find.byType(TmbChoiceTile),
      then: (tester, env) async {
        for (final step in orderingTask.items) {
          await env.tapText(step, upper: false);
        }
      },
    );
    archetype(
      'spatial: показ',
      spatialTask,
      expects: () => find.text('Б'),
      then: (tester, env) => env.tapText(l10n.sessionStudyDone),
    );
    archetype(
      'delayed_recall: запоминание',
      delayedTask,
      expects: () => find.text('Пост номер три'),
    );
    archetype(
      'verbal: речь и смена условия',
      verbalTask,
      then: (tester, env) async {
        await env.advance(3500);
        expect(find.text(l10n.sessionCueTitle.toUpperCase()), findsOneWidget);
      },
    );
    archetype(
      'verbal: самопроверка',
      verbalTask,
      then: (tester, env) => env.tapText(l10n.sessionVerbalFinish),
    );
  });

  testWidgets(
    'широкая сетка spatial прокручивается, клетки не мельче цели касания',
    (tester) async {
      const wide = SpatialTask(
        id: 'test.spatial.wide',
        domain: 'cog.test.spatial',
        timeSec: 20,
        difficulty: 0.3,
        prompt: 'Где была отметка?',
        grid: GridSize(rows: 2, cols: 12),
        answer: CellPosition(row: 0, col: 11),
        objects: [SpatialObject(label: 'X', row: 0, col: 11)],
        showSec: 5,
      );
      final env = await _pump(tester, [wide]);
      await env.completeRound();
      _noOverflow(tester);
      final cells = find.descendant(
        of: find.byType(SpatialGridView),
        matching: find.byType(GestureDetector),
      );
      expect(cells, findsNWidgets(2 * 12));
      expect(
        tester.getSize(cells.first).width,
        greaterThanOrEqualTo(TmbSize.tapTarget),
      );
      expect(
        tester.getSize(cells.first).height,
        greaterThanOrEqualTo(TmbSize.tapTarget),
      );
      await env.unmount();
    },
  );
}
