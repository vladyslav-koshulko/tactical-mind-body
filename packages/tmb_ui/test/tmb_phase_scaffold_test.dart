import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'support/harness.dart';

Future<void> _pump(
  WidgetTester tester,
  TmbPhase phase, {
  double textScale = kLargeTextScale,
}) async {
  useScreen(tester);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: TmbPhaseScaffold(
        phase: phase,
        phaseLabel: phase == TmbPhase.physical
            ? 'Физическая фаза'
            : 'Когнитивная пауза',
        title: 'Круг 2 из 5, упражнение с очень длинным названием',
        body: Builder(
          builder: (context) => Text(
            TmbPhaseTheme.of(context).phase.name,
            key: const Key('body-phase'),
          ),
        ),
        bottom: TmbButton(
          label: 'Следующий круг',
          onPressed: null,
          expand: true,
        ),
      ),
    ),
  );
}

void main() {
  group('TmbPhaseScaffold', () {
    for (final phase in TmbPhase.values) {
      testWidgets('влезает при 320 px и шрифте 1.5 ($phase)', (tester) async {
        await _pump(tester, phase);
        expectNoOverflow(tester);
      });
    }

    testWidgets('тема потомков меняется целиком вместе с фазой', (
      tester,
    ) async {
      await _pump(tester, TmbPhase.physical);
      expect(
        tester.widget<Text>(find.byKey(const Key('body-phase'))).data,
        'physical',
      );
      var theme = Theme.of(tester.element(find.byKey(const Key('body-phase'))));
      expect(theme.colorScheme.primary, TmbColor.accent500);

      await _pump(tester, TmbPhase.cognitive);
      expect(
        tester.widget<Text>(find.byKey(const Key('body-phase'))).data,
        'cognitive',
      );
      theme = Theme.of(tester.element(find.byKey(const Key('body-phase'))));
      expect(theme.colorScheme.primary, TmbColor.signal500);
    });

    testWidgets('кнопка внутри наследует фазу каркаса', (tester) async {
      await _pump(tester, TmbPhase.cognitive);
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style!.backgroundColor!.resolve({}), TmbColor.signal500);
      expect(
        button.style!.backgroundColor!.resolve({WidgetState.disabled}),
        TmbColor.raised,
      );
      expect(
        button.style!.backgroundColor!.resolve({WidgetState.pressed}),
        TmbColor.signal300,
      );
    });

    testWidgets('шапка красится по фазе и несёт форму + текст фазы', (
      tester,
    ) async {
      await _pump(tester, TmbPhase.physical);
      var glyph = tester.widget<TmbPhaseGlyph>(find.byType(TmbPhaseGlyph));
      expect(glyph.phase, TmbPhase.physical);
      expect(find.text('ФИЗИЧЕСКАЯ ФАЗА'), findsOneWidget);

      await _pump(tester, TmbPhase.cognitive);
      glyph = tester.widget<TmbPhaseGlyph>(find.byType(TmbPhaseGlyph));
      expect(glyph.phase, TmbPhase.cognitive);
      expect(find.text('КОГНИТИВНАЯ ПАУЗА'), findsOneWidget);

      final header = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.color == TmbPhase.cognitive.surface);
      expect(
        (header.border! as Border).bottom.color,
        TmbPhase.cognitive.border,
      );
    });

    testWidgets('без bottom и title рендерится', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: TmbPhaseScaffold(
            phase: TmbPhase.physical,
            phaseLabel: 'Физическая фаза',
            body: SizedBox.shrink(),
          ),
        ),
      );
      expectNoOverflow(tester);
      expect(find.byType(TmbButton), findsNothing);
    });
  });
}
