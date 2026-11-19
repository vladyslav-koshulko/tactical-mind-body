import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'support/harness.dart';

Widget _timer({
  TmbPhase? phase,
  double progress = 0.5,
  String phaseLabel = 'Физическая фаза',
}) => TmbRadarTimer(
  timeText: '00:45',
  progress: progress,
  phaseLabel: phaseLabel,
  semanticLabel: 'Осталось 45 секунд',
  phase: phase,
);

TmbRadarPainter _painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .whereType<TmbRadarPainter>()
    .single;

void main() {
  group('TmbRadarTimer', () {
    testWidgets('влезает при 320 px и шрифте 1.5, круг не шире экрана', (
      tester,
    ) async {
      await pumpNarrow(tester, SizedBox(width: kNarrowWidth, child: _timer()));
      expectNoOverflow(tester);
      final size = tester.getSize(find.byType(TmbRadarTimer));
      expect(size.width, lessThanOrEqualTo(kNarrowWidth));
    });

    testWidgets('на очень узком экране круг сжимается, а не переполняет', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        SizedBox(width: 200, child: _timer(phaseLabel: 'Когнитивная фаза')),
        width: 200,
      );
      expectNoOverflow(tester);
      expect(tester.getSize(find.byType(CustomPaint).first).width, 200);
    });

    testWidgets('диаметр ограничен TmbSize.radarMax на широком экране', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        SizedBox(width: 600, child: _timer()),
        width: 600,
        textScale: 1,
      );
      final sizes = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((p) => p.painter is TmbRadarPainter)
          .map((p) => p.size);
      expect(sizes.single, const Size.square(TmbSize.radarMax));
    });

    testWidgets('показывает время и подпись фазы капсом', (tester) async {
      await pumpNarrow(tester, _timer());
      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('ФИЗИЧЕСКАЯ ФАЗА'), findsOneWidget);
    });

    testWidgets('фаза дублируется формой: глиф квадрат vs ромб', (
      tester,
    ) async {
      await pumpNarrow(tester, _timer(phase: TmbPhase.physical));
      final physical = tester.widget<TmbPhaseGlyph>(find.byType(TmbPhaseGlyph));
      expect(physical.phase, TmbPhase.physical);

      await pumpNarrow(
        tester,
        _timer(phase: TmbPhase.cognitive, phaseLabel: 'Когнитивная пауза'),
      );
      final cognitive = tester.widget<TmbPhaseGlyph>(
        find.byType(TmbPhaseGlyph),
      );
      expect(cognitive.phase, TmbPhase.cognitive);
      expect(find.text('КОГНИТИВНАЯ ПАУЗА'), findsOneWidget);
      // Форма в одном и том же цвете действительно разная.
      const size = Size.square(kTmbPhaseGlyphSize);
      expect(
        TmbPhaseGlyphPainter.buildPath(
          TmbPhase.physical,
          size,
        ).contains(const Offset(1, 1)),
        isTrue,
      );
      expect(
        TmbPhaseGlyphPainter.buildPath(
          TmbPhase.cognitive,
          size,
        ).contains(const Offset(1, 1)),
        isFalse,
      );
    });

    testWidgets('дуга рисуется цветом фазы и длиной по progress', (
      tester,
    ) async {
      await pumpNarrow(
        tester,
        _timer(phase: TmbPhase.cognitive, progress: 0.25),
      );
      final painter = _painter(tester);
      expect(painter.phase, TmbPhase.cognitive);
      expect(painter.sweep, closeTo(math.pi / 2, 1e-9));

      final render = tester.renderObject(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is TmbRadarPainter,
        ),
      );
      expect(
        render,
        paints..arc(color: TmbColor.signal500, strokeWidth: TmbStroke.radar),
      );
    });

    testWidgets('при progress = 0 дуги нет, остаётся дорожка', (tester) async {
      await pumpNarrow(tester, _timer(progress: 0));
      final render = tester.renderObject(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is TmbRadarPainter,
        ),
      );
      expect(render, isNot(paints..arc()));
      // Два кольца сетки, затем дорожка.
      expect(
        render,
        paints
          ..circle()
          ..circle()
          ..circle(color: TmbColor.borderDefault),
      );
    });

    test('shouldRepaint реагирует на фазу и прогресс', () {
      const base = TmbRadarPainter(phase: TmbPhase.physical, progress: 0.5);
      expect(
        base.shouldRepaint(
          const TmbRadarPainter(phase: TmbPhase.physical, progress: 0.5),
        ),
        isFalse,
      );
      expect(
        base.shouldRepaint(
          const TmbRadarPainter(phase: TmbPhase.cognitive, progress: 0.5),
        ),
        isTrue,
      );
      expect(
        base.shouldRepaint(
          const TmbRadarPainter(phase: TmbPhase.physical, progress: 0.4),
        ),
        isTrue,
      );
    });

    testWidgets('скринридер получает одну цельную подпись', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNarrow(tester, _timer());
      expect(find.bySemanticsLabel('Осталось 45 секунд'), findsOneWidget);
      handle.dispose();
    });
  });
}
