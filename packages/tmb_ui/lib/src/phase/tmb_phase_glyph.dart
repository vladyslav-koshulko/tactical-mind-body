import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';

/// Размер глифа по умолчанию. Различимость форм проверена на 16 px.
const double kTmbPhaseGlyphSize = 16;

/// Нецветовой канал фазы (инвариант 6): физика — КВАДРАТ, когниция — РОМБ.
///
/// Обе фигуры вписаны в один и тот же квадрат и закрашены сплошным цветом,
/// поэтому различаются даже в монохроме и при дейтеранопии.
class TmbPhaseGlyph extends StatelessWidget {
  const TmbPhaseGlyph({
    required this.phase,
    required this.semanticLabel,
    this.size = kTmbPhaseGlyphSize,
    this.color,
    super.key,
  });

  final TmbPhase phase;

  /// Локализованная подпись для скринридера (строка приходит из ARB).
  final String semanticLabel;
  final double size;

  /// По умолчанию — акцент фазы. Переопределять нужно только для проверок.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.square(size),
          painter: TmbPhaseGlyphPainter(
            phase: phase,
            color: color ?? phase.accent,
          ),
        ),
      ),
    );
  }
}

/// Рисует форму фазы. [buildPath] открыт, чтобы форму можно было сверить в тесте.
class TmbPhaseGlyphPainter extends CustomPainter {
  const TmbPhaseGlyphPainter({required this.phase, required this.color});

  final TmbPhase phase;
  final Color color;

  /// Контур глифа в границах [size].
  static Path buildPath(TmbPhase phase, Size size) {
    final w = size.width;
    final h = size.height;
    switch (phase) {
      case TmbPhase.physical:
        return Path()..addRect(Rect.fromLTWH(0, 0, w, h));
      case TmbPhase.cognitive:
        return Path()
          ..moveTo(w / 2, 0)
          ..lineTo(w, h / 2)
          ..lineTo(w / 2, h)
          ..lineTo(0, h / 2)
          ..close();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(buildPath(phase, size), Paint()..color = color);
  }

  @override
  bool shouldRepaint(TmbPhaseGlyphPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

/// Глиф + текстовая подпись фазы. Капс — свойство стиля, строка обычная.
class TmbPhaseBadge extends StatelessWidget {
  const TmbPhaseBadge({required this.phase, required this.label, super.key});

  final TmbPhase phase;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TmbPhaseGlyph(phase: phase, semanticLabel: label),
        const SizedBox(width: TmbSpace.x2),
        Flexible(
          // Подпись уже озвучена глифом — не дублируем для скринридера.
          child: ExcludeSemantics(
            child: Text(
              label.toUpperCase(),
              style: TmbType.labelMd.copyWith(color: phase.accent),
            ),
          ),
        ),
      ],
    );
  }
}
