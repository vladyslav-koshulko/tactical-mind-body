import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'support/harness.dart';

const _items = [
  TmbExerciseItem(
    name: 'Отжимания',
    targetValue: 20,
    targetUnit: 'повт.',
    status: TmbExerciseStatus.done,
    statusLabel: 'Выполнено',
  ),
  TmbExerciseItem(
    name: 'Выпрыгивания из приседа с хлопком над головой',
    targetValue: 45,
    targetUnit: 'секунд',
    status: TmbExerciseStatus.current,
    statusLabel: 'Текущее',
  ),
  TmbExerciseItem(
    name: 'Планка',
    targetValue: 60,
    targetUnit: 'с',
    status: TmbExerciseStatus.upcoming,
    statusLabel: 'Впереди',
  ),
];

Finder _row(String nameUpper) => find.ancestor(
  of: find.text(nameUpper),
  matching: find.byType(TmbExerciseRow),
);

void main() {
  group('TmbRoundList', () {
    testWidgets('влезает при 320 px и шрифте 1.5, строки >= 48', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        const SizedBox(
          width: kNarrowWidth,
          child: TmbRoundList(items: _items, title: 'Круг 2 из 5'),
        ),
      );
      expectNoOverflow(tester);
      expect(find.byType(TmbExerciseRow), findsNWidgets(3));
      for (final e in find.byType(TmbExerciseRow).evaluate()) {
        final size = tester.getSize(find.byWidget(e.widget));
        expect(size.height, greaterThanOrEqualTo(TmbSize.tapTarget));
        expect(size.width, kNarrowWidth);
      }
    });

    testWidgets('показывает заголовок капсом, названия и цели из параметров', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        const SizedBox(
          width: kNarrowWidth,
          child: TmbRoundList(items: _items, title: 'Круг 2 из 5'),
        ),
        textScale: 1,
      );
      expect(find.text('КРУГ 2 ИЗ 5'), findsOneWidget);
      expect(find.text('ОТЖИМАНИЯ'), findsOneWidget);
      expect(find.text('20 повт.'), findsOneWidget);
      expect(find.text('45 секунд'), findsOneWidget);
      expect(find.text('60 с'), findsOneWidget);
    });

    testWidgets('без title заголовка нет', (tester) async {
      await pumpNarrow(
        tester,
        const SizedBox(
          width: kNarrowWidth,
          child: TmbRoundList(items: _items),
        ),
      );
      expect(find.byType(Text), findsNWidgets(_items.length * 2));
    });

    testWidgets('состояние читается без цвета: маркер и зачёркивание', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        const SizedBox(
          width: kNarrowWidth,
          child: TmbRoundList(items: _items),
        ),
        textScale: 1,
      );
      Finder icon(IconData i, String name) =>
          find.descendant(of: _row(name), matching: find.byIcon(i));

      // Выполнено — галочка, текущее — стрелка, впереди — иконки нет.
      expect(icon(Icons.check, 'ОТЖИМАНИЯ'), findsOneWidget);
      expect(icon(Icons.play_arrow, 'ОТЖИМАНИЯ'), findsNothing);
      final current = 'ВЫПРЫГИВАНИЯ ИЗ ПРИСЕДА С ХЛОПКОМ НАД ГОЛОВОЙ';
      expect(icon(Icons.play_arrow, current), findsOneWidget);
      expect(icon(Icons.check, 'ПЛАНКА'), findsNothing);
      expect(icon(Icons.play_arrow, 'ПЛАНКА'), findsNothing);

      TextDecoration? decoration(String name) =>
          tester.widget<Text>(find.text(name)).style!.decoration;
      expect(decoration('ОТЖИМАНИЯ'), TextDecoration.lineThrough);
      expect(decoration('ПЛАНКА'), isNull);
      expect(decoration(current), isNull);
    });

    testWidgets('текущая строка обведена рамкой цвета фазы, прочие — нет', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        const SizedBox(
          width: kNarrowWidth,
          child: TmbRoundList(items: _items, phase: TmbPhase.cognitive),
        ),
        textScale: 1,
      );
      Border border(String name) {
        final box = tester.widget<Container>(
          find
              .descendant(of: _row(name), matching: find.byType(Container))
              .first,
        );
        return (box.decoration! as BoxDecoration).border! as Border;
      }

      final current = border('ВЫПРЫГИВАНИЯ ИЗ ПРИСЕДА С ХЛОПКОМ НАД ГОЛОВОЙ');
      final other = border('ПЛАНКА');
      expect(current.top.color, TmbColor.signal500);
      expect(other.top.color, TmbColor.borderSubtle);
      // Одинаковая толщина — раскладка не прыгает при смене текущего.
      expect(current.top.width, other.top.width);
    });

    testWidgets('скринридер: статус, название и цель в одной подписи', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpNarrow(
        tester,
        const SizedBox(
          width: kNarrowWidth,
          child: TmbRoundList(items: _items),
        ),
      );
      expect(
        find.bySemanticsLabel('Выполнено, Отжимания, 20 повт.'),
        findsOneWidget,
      );
      bool? selected(String label) => tester
          .getSemantics(find.bySemanticsLabel(label))
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull();
      expect(selected('Выполнено, Отжимания, 20 повт.'), isFalse);
      expect(
        selected(
          'Текущее, Выпрыгивания из приседа с хлопком над головой, 45 секунд',
        ),
        isTrue,
      );
      handle.dispose();
    });
  });
}
