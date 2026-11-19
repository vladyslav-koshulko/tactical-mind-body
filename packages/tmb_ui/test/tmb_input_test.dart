import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'support/harness.dart';

const _labels = ['Не смог', 'Частично', 'Почти', 'Точно'];

Widget _rating({int? value, ValueChanged<int>? onChanged}) => SizedBox(
  width: kNarrowWidth,
  child: TmbSelfRatingBar(
    value: value,
    onChanged: onChanged ?? (_) {},
    labels: _labels,
  ),
);

Widget _effort({TmbEffort? value, ValueChanged<TmbEffort>? onChanged}) =>
    SizedBox(
      width: kNarrowWidth,
      child: TmbEffortPicker(
        value: value,
        onChanged: onChanged ?? (_) {},
        hardLabel: 'Тяжело',
        normalLabel: 'Нормально',
        easyLabel: 'Легко',
      ),
    );

void main() {
  group('TmbSelfRatingBar', () {
    testWidgets('влезает при 320 px и шрифте 1.5, цели >= 48', (tester) async {
      await pumpNarrow(tester, _rating(value: 2));
      expectNoOverflow(tester);
      expect(find.byType(TextButton), findsNWidgets(4));
      expectTapTargets(
        tester,
        find.byType(TmbSelfRatingBar),
        TmbSize.tapTarget,
      );
    });

    testWidgets('нажатие на i-ю плитку отдаёт i', (tester) async {
      final picked = <int>[];
      await pumpNarrow(tester, _rating(onChanged: picked.add));
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.widgetWithText(TextButton, '$i'));
      }
      expect(picked, [0, 1, 2, 3]);
    });

    testWidgets('показывает подписи капсом', (tester) async {
      await pumpNarrow(tester, _rating());
      expect(find.text('НЕ СМОГ'), findsOneWidget);
      expect(find.text('ТОЧНО'), findsOneWidget);
    });

    testWidgets('выбранность: галочка только у выбранной, не только цвет', (
      tester,
    ) async {
      await pumpNarrow(tester, _rating(value: 1));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(TextButton, '1'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      // Значение 0 — тоже выбор, не «пусто».
      await pumpNarrow(tester, _rating(value: 0));
      expect(
        find.descendant(
          of: find.widgetWithText(TextButton, '0'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      await pumpNarrow(tester, _rating());
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('выбранная заливается цветом фазы', (tester) async {
      await pumpNarrow(tester, _rating(value: 3), phase: TmbPhase.cognitive);
      Color fill(String digit) => tester
          .widget<TextButton>(find.widgetWithText(TextButton, digit))
          .style!
          .backgroundColor!
          .resolve({})!;
      expect(fill('3'), TmbColor.signal500);
      expect(fill('2'), TmbColor.raised);
    });

    test('нужно ровно четыре подписи', () {
      expect(
        () =>
            TmbSelfRatingBar(value: null, onChanged: (_) {}, labels: const []),
        throwsAssertionError,
      );
    });
  });

  group('TmbEffortPicker', () {
    testWidgets('влезает при 320 px и шрифте 1.5, цели >= 48', (tester) async {
      await pumpNarrow(tester, _effort(value: TmbEffort.normal));
      expectNoOverflow(tester);
      expect(find.byType(TextButton), findsNWidgets(3));
      expectTapTargets(tester, find.byType(TmbEffortPicker), TmbSize.tapTarget);
    });

    testWidgets('одно нажатие — одно значение', (tester) async {
      final picked = <TmbEffort>[];
      await pumpNarrow(tester, _effort(onChanged: picked.add));
      await tester.tap(find.text('ЛЕГКО'));
      await tester.tap(find.text('ТЯЖЕЛО'));
      await tester.tap(find.text('НОРМАЛЬНО'));
      expect(picked, [TmbEffort.easy, TmbEffort.hard, TmbEffort.normal]);
    });

    testWidgets('выбранный отмечен галочкой, остальные — нет', (tester) async {
      await pumpNarrow(tester, _effort(value: TmbEffort.hard));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(TextButton, 'ТЯЖЕЛО'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('скринридер: выбранность в семантике', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNarrow(tester, _effort(value: TmbEffort.easy));
      expect(
        tester.getSemantics(find.bySemanticsLabel('ЛЕГКО')),
        matchesSemantics(
          label: 'ЛЕГКО',
          isButton: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: false,
          hasTapAction: true,
          hasSelectedState: true,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });
  });
}
