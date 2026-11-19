import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'support/harness.dart';

ButtonStyle _style(WidgetTester tester) =>
    tester.widget<TextButton>(find.byType(TextButton)).style!;

void main() {
  group('TmbButton', () {
    testWidgets('все варианты влезают при 320 px и шрифте 1.5, цель >= 48', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final v in TmbButtonVariant.values)
              SizedBox(
                width: kNarrowWidth,
                child: TmbButton(
                  label: 'Подтвердить ответ и перейти дальше',
                  onPressed: () {},
                  variant: v,
                  expand: true,
                ),
              ),
          ],
        ),
      );
      expectNoOverflow(tester);
      expectTapTargets(tester, find.byType(Column), TmbSize.tapTarget);
    });

    testWidgets('короткая кнопка не меньше 48x48', (tester) async {
      await pumpNarrow(
        tester,
        TmbButton(
          label: 'Ок',
          onPressed: () {},
          variant: TmbButtonVariant.ghost,
        ),
        textScale: 1,
      );
      final size = tester.getSize(find.byType(TextButton));
      expect(size.width, greaterThanOrEqualTo(TmbSize.tapTarget));
      expect(size.height, greaterThanOrEqualTo(TmbSize.tapTarget));
    });

    testWidgets('капс делает виджет, а не строка', (tester) async {
      await pumpNarrow(tester, TmbButton(label: 'Начать', onPressed: () {}));
      expect(find.text('НАЧАТЬ'), findsOneWidget);
      expect(find.text('Начать'), findsNothing);
    });

    testWidgets('нажатие вызывает колбэк, disabled — нет', (tester) async {
      var taps = 0;
      await pumpNarrow(
        tester,
        TmbButton(label: 'Дальше', onPressed: () => taps++),
      );
      await tester.tap(find.byType(TextButton));
      expect(taps, 1);

      await pumpNarrow(tester, TmbButton(label: 'Дальше', onPressed: null));
      await tester.tap(find.byType(TextButton), warnIfMissed: false);
      expect(taps, 1);
    });

    testWidgets('primary: заливка по фазе, pressed светлее, disabled гаснет', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        TmbButton(label: 'А', onPressed: () {}, phase: TmbPhase.physical),
      );
      var bg = _style(tester).backgroundColor!;
      expect(bg.resolve({}), TmbColor.accent500);
      expect(bg.resolve({WidgetState.pressed}), TmbColor.accent300);
      expect(bg.resolve({WidgetState.disabled}), TmbColor.raised);
      expect(_style(tester).foregroundColor!.resolve({}), TmbColor.textInverse);

      await pumpNarrow(
        tester,
        TmbButton(label: 'А', onPressed: () {}, phase: TmbPhase.cognitive),
      );
      bg = _style(tester).backgroundColor!;
      expect(bg.resolve({}), TmbColor.signal500);
      expect(bg.resolve({WidgetState.pressed}), TmbColor.signal300);
    });

    testWidgets('фаза наследуется из темы, если не задана', (tester) async {
      await pumpNarrow(
        tester,
        TmbButton(label: 'А', onPressed: () {}),
        phase: TmbPhase.cognitive,
      );
      expect(_style(tester).backgroundColor!.resolve({}), TmbColor.signal500);
    });

    testWidgets('secondary / ghost / danger: стили различаются', (
      tester,
    ) async {
      Future<ButtonStyle> styleOf(TmbButtonVariant v) async {
        await pumpNarrow(
          tester,
          TmbButton(label: 'А', onPressed: () {}, variant: v),
        );
        return _style(tester);
      }

      final secondary = await styleOf(TmbButtonVariant.secondary);
      expect(secondary.backgroundColor!.resolve({}), Colors.transparent);
      expect(secondary.side!.resolve({})!.color, TmbColor.borderDefault);
      expect(
        secondary.side!.resolve({WidgetState.pressed})!.color,
        TmbPhase.physical.accent,
      );

      final ghost = await styleOf(TmbButtonVariant.ghost);
      expect(ghost.foregroundColor!.resolve({}), TmbPhase.physical.accent);
      expect(ghost.side!.resolve({}), BorderSide.none);

      final danger = await styleOf(TmbButtonVariant.danger);
      expect(danger.foregroundColor!.resolve({}), TmbColor.danger);
      expect(danger.side!.resolve({})!.color, TmbColor.danger);
      expect(
        danger.backgroundColor!.resolve({WidgetState.pressed}),
        TmbColor.danger,
      );
      expect(
        danger.foregroundColor!.resolve({WidgetState.disabled}),
        TmbColor.textMuted,
      );
    });

    testWidgets('expand растягивает на всю ширину', (tester) async {
      await pumpNarrow(
        tester,
        SizedBox(
          width: kNarrowWidth,
          child: TmbButton(label: 'А', onPressed: () {}, expand: true),
        ),
        textScale: 1,
      );
      expect(tester.getSize(find.byType(TextButton)).width, kNarrowWidth);
    });
  });
}
