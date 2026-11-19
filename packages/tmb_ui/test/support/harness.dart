import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Узкий экран из требований: ширина 320 логических px.
const kNarrowWidth = 320.0;

/// Высота с запасом, чтобы вертикальный overflow был виден как ошибка, а не
/// прятался за прокруткой.
const kTallHeight = 2000.0;

/// Крупный системный шрифт из требований.
const kLargeTextScale = 1.5;

/// Выставляет размер окна теста и убирает его после теста.
void useScreen(
  WidgetTester tester, {
  double width = kNarrowWidth,
  double height = kTallHeight,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

/// Кладёт [child] в приложение на узком экране с крупным шрифтом.
///
/// Шрифты Oswald/JetBrains Mono в `flutter test` не грузятся — рисуется Ahem,
/// у которого глиф шире настоящих; для проверок «влезает» это запас прочности.
Future<void> pumpNarrow(
  WidgetTester tester,
  Widget child, {
  double width = kNarrowWidth,
  double textScale = kLargeTextScale,
  TmbPhase phase = TmbPhase.physical,
}) async {
  useScreen(tester, width: width);
  await tester.pumpWidget(
    MaterialApp(
      theme: TmbTheme.dark(phase: phase),
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

/// Ни одного overflow/исключения за время теста.
void expectNoOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

/// Все `TextButton` внутри [root] не меньше [min] по обеим осям.
void expectTapTargets(WidgetTester tester, Finder root, double min) {
  final buttons = find.descendant(of: root, matching: find.byType(TextButton));
  expect(buttons, findsWidgets);
  for (final element in buttons.evaluate()) {
    final size = tester.getSize(find.byWidget(element.widget));
    expect(size.width, greaterThanOrEqualTo(min), reason: 'ширина цели');
    expect(size.height, greaterThanOrEqualTo(min), reason: 'высота цели');
  }
}
