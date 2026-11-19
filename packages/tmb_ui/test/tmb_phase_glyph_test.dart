import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

const _physicalLabel = 'physical-label';
const _cognitiveLabel = 'cognitive-label';

TmbPhaseGlyphPainter _painterOf(WidgetTester tester, String label) {
  final paint = tester.widget<CustomPaint>(
    find
        .descendant(
          of: find.bySemanticsLabel(label),
          matching: find.byType(CustomPaint),
        )
        .first,
  );
  return paint.painter! as TmbPhaseGlyphPainter;
}

void main() {
  testWidgets('оба глифа рендерятся 16x16 и несут подпись', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: const [
            TmbPhaseGlyph(
              phase: TmbPhase.physical,
              semanticLabel: _physicalLabel,
            ),
            TmbPhaseGlyph(
              phase: TmbPhase.cognitive,
              semanticLabel: _cognitiveLabel,
            ),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel(_physicalLabel), findsOneWidget);
    expect(find.bySemanticsLabel(_cognitiveLabel), findsOneWidget);
    expect(
      tester.getSize(find.bySemanticsLabel(_physicalLabel)),
      const Size.square(kTmbPhaseGlyphSize),
    );
    expect(
      _painterOf(tester, _physicalLabel).phase,
      isNot(_painterOf(tester, _cognitiveLabel).phase),
    );
  });

  test('форма различается в одном цвете: квадрат против ромба', () {
    const size = Size.square(kTmbPhaseGlyphSize);
    final square = TmbPhaseGlyphPainter.buildPath(TmbPhase.physical, size);
    final diamond = TmbPhaseGlyphPainter.buildPath(TmbPhase.cognitive, size);

    // Границы одинаковы, а контуры — нет.
    expect(square.getBounds(), diamond.getBounds());
    // Угол квадрата закрашен, угол ромба — пуст.
    const corner = Offset(1, 1);
    expect(square.contains(corner), isTrue);
    expect(diamond.contains(corner), isFalse);
    // Центр закрашен у обоих.
    const center = Offset(kTmbPhaseGlyphSize / 2, kTmbPhaseGlyphSize / 2);
    expect(square.contains(center), isTrue);
    expect(diamond.contains(center), isTrue);

    // Один и тот же цвет не делает painter'ы равными по форме.
    const sameColor = TmbColor.textPrimary;
    const physical = TmbPhaseGlyphPainter(
      phase: TmbPhase.physical,
      color: sameColor,
    );
    const cognitive = TmbPhaseGlyphPainter(
      phase: TmbPhase.cognitive,
      color: sameColor,
    );
    expect(cognitive.shouldRepaint(physical), isTrue);
  });

  testWidgets('бейдж показывает текст подписи капсом', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TmbPhaseBadge(phase: TmbPhase.cognitive, label: 'Когнитивная'),
      ),
    );
    expect(find.text('КОГНИТИВНАЯ'), findsOneWidget);
  });
}
