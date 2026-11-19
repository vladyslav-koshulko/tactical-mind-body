import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'support/harness.dart';

const _backspace = 'Стереть';
const _submit = 'Подтвердить';

Widget _keypad({
  ValueChanged<int>? onDigit,
  VoidCallback? onBackspace,
  VoidCallback? onSubmit,
  VoidCallback? onMinus,
  VoidCallback? onDecimal,
  bool submitEnabled = true,
}) => SizedBox(
  width: kNarrowWidth,
  child: TmbNumericKeypad(
    onDigit: onDigit ?? (_) {},
    onBackspace: onBackspace ?? () {},
    onSubmit: submitEnabled ? (onSubmit ?? () {}) : null,
    onMinus: onMinus,
    onDecimal: onDecimal,
    minusLabel: onMinus == null ? null : 'Минус',
    decimalLabel: onDecimal == null ? null : 'Запятая',
    backspaceLabel: _backspace,
    submitLabel: _submit,
  ),
);

void main() {
  group('TmbNumericKeypad', () {
    testWidgets('влезает при 320 px и шрифте 1.5 (со всеми клавишами)', (
      tester,
    ) async {
      await pumpNarrow(tester, _keypad(onMinus: () {}, onDecimal: () {}));
      expectNoOverflow(tester);
      expect(tester.getSize(find.byType(TmbNumericKeypad)).width, kNarrowWidth);
    });

    testWidgets('все клавиши не меньше 56 px (в коде — TmbSize.keypadKey)', (
      tester,
    ) async {
      expect(TmbSize.keypadKey, greaterThanOrEqualTo(56));
      await pumpNarrow(
        tester,
        _keypad(onMinus: () {}, onDecimal: () {}),
        textScale: 1,
      );
      // 10 цифр + минус + запятая + стереть + подтвердить.
      expect(find.byType(TextButton), findsNWidgets(14));
      expectTapTargets(tester, find.byType(TmbNumericKeypad), 56);
    });

    testWidgets('клавиши не меньше 56 px и при шрифте 1.5', (tester) async {
      await pumpNarrow(tester, _keypad());
      expectNoOverflow(tester);
      expectTapTargets(tester, find.byType(TmbNumericKeypad), 56);
    });

    testWidgets('каждая цифра вызывает onDigit со своим значением', (
      tester,
    ) async {
      final digits = <int>[];
      await pumpNarrow(tester, _keypad(onDigit: digits.add));
      for (var d = 0; d <= 9; d++) {
        await tester.tap(find.widgetWithText(TextButton, '$d'));
      }
      expect(digits, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    testWidgets('стереть и подтвердить вызывают свои колбэки', (tester) async {
      var erased = 0;
      var submitted = 0;
      await pumpNarrow(
        tester,
        _keypad(onBackspace: () => erased++, onSubmit: () => submitted++),
      );
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.tap(find.text(_submit.toUpperCase()));
      expect(erased, 1);
      expect(submitted, 1);
    });

    testWidgets('подтверждение недоступно при onSubmit == null', (
      tester,
    ) async {
      await pumpNarrow(tester, _keypad(submitEnabled: false));
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, _submit.toUpperCase()),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('минус и запятая появляются только по запросу', (tester) async {
      await pumpNarrow(tester, _keypad());
      expect(find.text(TmbNumericKeypad.minusSign), findsNothing);
      expect(find.text(','), findsNothing);
      expect(find.byType(TextButton), findsNWidgets(12));

      var minus = 0;
      var decimal = 0;
      await pumpNarrow(
        tester,
        _keypad(onMinus: () => minus++, onDecimal: () => decimal++),
      );
      await tester.tap(find.text(TmbNumericKeypad.minusSign));
      await tester.tap(find.text(','));
      expect((minus, decimal), (1, 1));
    });

    testWidgets('раскладка постоянна: цифра 0 стоит в центре нижнего ряда', (
      tester,
    ) async {
      await pumpNarrow(tester, _keypad(), textScale: 1);
      final zero = tester.getCenter(find.widgetWithText(TextButton, '0'));
      final eight = tester.getCenter(find.widgetWithText(TextButton, '8'));
      expect(zero.dx, closeTo(eight.dx, 0.5));
      expect(zero.dy, greaterThan(eight.dy));
    });

    testWidgets('скринридер: у иконочных клавиш есть подписи', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNarrow(tester, _keypad(onMinus: () {}, onDecimal: () {}));
      expect(find.bySemanticsLabel(_backspace), findsOneWidget);
      expect(find.bySemanticsLabel('Минус'), findsOneWidget);
      expect(find.bySemanticsLabel('Запятая'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('подтверждение красится по фазе', (tester) async {
      await pumpNarrow(tester, _keypad(), phase: TmbPhase.cognitive);
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, _submit.toUpperCase()),
      );
      expect(button.style!.backgroundColor!.resolve({}), TmbColor.signal500);
    });
  });
}
