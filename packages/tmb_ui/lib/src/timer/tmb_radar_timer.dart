import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_glyph.dart';
import '../phase/tmb_phase_theme.dart';

/// Круговой радар-таймер по центру экрана тренировки.
///
/// Чисто презентационный: оставшееся время приходит готовой строкой
/// ([timeText], например `00:45`), доля оставшегося — числом [progress].
/// Фаза передаётся двумя каналами (инвариант 6): цвет дуги и
/// [TmbPhaseGlyph] с подписью [phaseLabel] внутри круга.
///
/// Диаметр — не больше [TmbSize.radarMax], на узком экране круг сжимается;
/// содержимое при крупном системном шрифте уменьшается, а не вылезает.
class TmbRadarTimer extends StatelessWidget {
  const TmbRadarTimer({
    required this.timeText,
    required this.progress,
    required this.phaseLabel,
    required this.semanticLabel,
    this.phase,
    super.key,
  }) : assert(progress >= 0 && progress <= 1);

  /// Оставшееся время цифрами, уже отформатированное.
  final String timeText;

  /// Доля оставшегося времени: `1` — полный круг, `0` — пустой.
  final double progress;

  /// Название фазы («Физическая фаза»); капс делает виджет.
  final String phaseLabel;

  /// Описание для скринридера целиком («Осталось 45 секунд, физическая фаза»).
  final String semanticLabel;

  /// `null` — наследовать фазу из темы.
  final TmbPhase? phase;

  @override
  Widget build(BuildContext context) {
    final effective = phase ?? TmbPhaseTheme.of(context).phase;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = math.min(
            TmbSize.radarMax,
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : TmbSize.radarMax,
          );
          const inset = TmbStroke.radar + TmbSpace.x6;
          final inner = diameter - 2 * inset;
          return Center(
            child: CustomPaint(
              size: Size.square(diameter),
              painter: TmbRadarPainter(phase: effective, progress: progress),
              child: SizedBox.square(
                dimension: diameter,
                child: Center(
                  child: SizedBox.square(
                    dimension: inner,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: inner),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                timeText,
                                maxLines: 1,
                                style: TmbType.dataTimer.copyWith(
                                  color: TmbColor.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: TmbSpace.x2),
                            TmbPhaseBadge(phase: effective, label: phaseLabel),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Рисует радар: дорожка, две сетки-кольца и дуга остатка по часовой от «12».
class TmbRadarPainter extends CustomPainter {
  const TmbRadarPainter({required this.phase, required this.progress});

  final TmbPhase phase;

  /// Доля оставшегося времени, `0..1`.
  final double progress;

  // Радиусы сетки как доли внешнего радиуса — геометрия, не визуальные токены.
  static const _gridFractions = [2 / 3, 1 / 3];
  static const _startAngle = -math.pi / 2;

  /// Угол дуги остатка, рад.
  double get sweep => 2 * math.pi * progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Дуга рисуется по центру штриха: отступаем на половину толщины.
    final radius = size.shortestSide / 2 - TmbStroke.radar / 2;

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = TmbStroke.thin
      ..color = TmbColor.borderSubtle;
    for (final f in _gridFractions) {
      canvas.drawCircle(center, radius * f, grid);
    }

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = TmbStroke.radar
      ..color = TmbColor.borderDefault;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = TmbStroke.radar
      ..strokeCap = StrokeCap.butt
      ..color = phase.accent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(TmbRadarPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.progress != progress;
}
