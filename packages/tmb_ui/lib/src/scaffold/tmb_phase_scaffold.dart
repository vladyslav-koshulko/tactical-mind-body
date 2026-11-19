import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_glyph.dart';
import '../theme/tmb_theme.dart';

/// Каркас экрана тренировки, целиком перекрашиваемый по фазе (DESIGN.md:
/// «Экран целиком меняет акцент при переходе в паузу»).
///
/// Оборачивает содержимое в `TmbTheme.dark(phase: phase)`, поэтому все
/// вложенные `TmbButton`, клавиатура, список и т. д., у которых `phase` не
/// задан явно, подхватывают акцент сами.
///
/// Фаза дублируется нецветовым каналом (инвариант 6): в шапке всегда
/// [TmbPhaseBadge] — форма (квадрат/ромб) и текст [phaseLabel].
///
/// Раскладка: шапка → [body] (занимает остаток, прокрутку обеспечивает
/// вызывающий) → [bottom] (закреплён внизу, например primary-кнопка).
/// Реклама сюда не помещается по замыслу (инвариант 10) — слота под неё нет.
class TmbPhaseScaffold extends StatelessWidget {
  const TmbPhaseScaffold({
    required this.phase,
    required this.phaseLabel,
    required this.body,
    this.title,
    this.bottom,
    super.key,
  });

  final TmbPhase phase;

  /// Название фазы для бейджа («Физическая фаза»); капс делает виджет.
  final String phaseLabel;

  /// Необязательный заголовок экрана под бейджем («Круг 2 из 5»).
  final String? title;

  final Widget body;

  /// Закреплённый низ экрана. `null` — нет.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TmbTheme.dark(phase: phase),
      child: Builder(
        builder: (context) => Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(phase: phase, phaseLabel: phaseLabel, title: title),
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: bottom == null,
                  child: Padding(
                    padding: const EdgeInsets.all(TmbSpace.x4),
                    child: body,
                  ),
                ),
              ),
              if (bottom != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TmbSpace.x4,
                      0,
                      TmbSpace.x4,
                      TmbSpace.x4,
                    ),
                    child: bottom,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.phase,
    required this.phaseLabel,
    required this.title,
  });

  final TmbPhase phase;
  final String phaseLabel;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: phase.surface,
        border: Border(
          bottom: BorderSide(color: phase.border, width: TmbStroke.base),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(TmbSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TmbPhaseBadge(phase: phase, label: phaseLabel),
              if (title != null) ...[
                const SizedBox(height: TmbSpace.x2),
                Text(
                  title!.toUpperCase(),
                  style: TmbType.displayLg.copyWith(
                    color: TmbColor.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
