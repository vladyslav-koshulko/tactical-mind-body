import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_theme.dart';

/// Вид кнопки (DESIGN.md, страница `02 Components`).
///
/// Правила: одна [primary] на экран; [danger] — только «Эвакуация».
enum TmbButtonVariant {
  /// Главное действие экрана. Заливка акцентом фазы.
  primary,

  /// Второстепенное действие: рамка без заливки.
  secondary,

  /// Третичное действие: только текст.
  ghost,

  /// Прерывание сессии. Больше нигде.
  danger,
}

/// Кнопка Tactical Mind & Body.
///
/// Цвет фазы берётся из [phase], а если он не задан — из ближайшей
/// `TmbPhaseTheme` (например, внутри `TmbPhaseScaffold`). Вариант «когнитивная
/// кнопка» — это `variant: primary, phase: TmbPhase.cognitive`.
///
/// Состояния: enabled, pressed, disabled (`onPressed == null`). Высота —
/// не меньше [TmbSize.tapTarget]; при крупном шрифте кнопка растёт, а не
/// обрезает подпись. Капс — свойство стиля: [label] приходит обычной строкой.
class TmbButton extends StatelessWidget {
  const TmbButton({
    required this.label,
    required this.onPressed,
    this.variant = TmbButtonVariant.primary,
    this.phase,
    this.expand = false,
    this.minHeight = TmbSize.tapTarget,
    super.key,
  }) : assert(minHeight >= TmbSize.tapTarget);

  /// Локализованная подпись (из ARB). Не должна быть уже в верхнем регистре.
  final String label;

  /// `null` — кнопка недоступна.
  final VoidCallback? onPressed;
  final TmbButtonVariant variant;

  /// `null` — наследовать фазу из темы.
  final TmbPhase? phase;

  /// Растянуть на всю доступную ширину.
  final bool expand;

  /// Нижняя граница высоты; не меньше цели касания.
  final double minHeight;

  /// Цвет нажатой заливки primary — на ступень светлее акцента.
  static Color _pressedFill(TmbPhase phase) => switch (phase) {
    TmbPhase.physical => TmbColor.accent300,
    TmbPhase.cognitive => TmbColor.signal300,
  };

  ButtonStyle _style(TmbPhase phase) {
    Color fill(Set<WidgetState> s) {
      final disabled = s.contains(WidgetState.disabled);
      final pressed = s.contains(WidgetState.pressed);
      if (disabled) {
        return variant == TmbButtonVariant.primary
            ? TmbColor.raised
            : Colors.transparent;
      }
      return switch (variant) {
        TmbButtonVariant.primary =>
          pressed ? _pressedFill(phase) : phase.accent,
        TmbButtonVariant.secondary || TmbButtonVariant.ghost =>
          pressed ? TmbColor.raised : Colors.transparent,
        TmbButtonVariant.danger =>
          pressed ? TmbColor.danger : Colors.transparent,
      };
    }

    Color foreground(Set<WidgetState> s) {
      if (s.contains(WidgetState.disabled)) return TmbColor.textMuted;
      final pressed = s.contains(WidgetState.pressed);
      return switch (variant) {
        TmbButtonVariant.primary => TmbColor.textInverse,
        TmbButtonVariant.secondary => TmbColor.textPrimary,
        TmbButtonVariant.ghost => phase.accent,
        TmbButtonVariant.danger =>
          pressed ? TmbColor.textInverse : TmbColor.danger,
      };
    }

    BorderSide side(Set<WidgetState> s) {
      final disabled = s.contains(WidgetState.disabled);
      final pressed = s.contains(WidgetState.pressed);
      final focused = s.contains(WidgetState.focused);
      if (focused && !disabled) {
        return BorderSide(color: phase.accent, width: TmbStroke.base);
      }
      return switch (variant) {
        TmbButtonVariant.primary || TmbButtonVariant.ghost => BorderSide.none,
        TmbButtonVariant.secondary => BorderSide(
          color: disabled
              ? TmbColor.borderSubtle
              : (pressed ? phase.accent : TmbColor.borderDefault),
          width: TmbStroke.base,
        ),
        TmbButtonVariant.danger => BorderSide(
          color: disabled ? TmbColor.borderSubtle : TmbColor.danger,
          width: TmbStroke.base,
        ),
      };
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(fill),
      foregroundColor: WidgetStateProperty.resolveWith(foreground),
      side: WidgetStateProperty.resolveWith(side),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: WidgetStatePropertyAll(Size(TmbSize.tapTarget, minHeight)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: TmbSpace.x6, vertical: TmbSpace.x3),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
        ),
      ),
      textStyle: const WidgetStatePropertyAll(TmbType.labelLg),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effective = phase ?? TmbPhaseTheme.of(context).phase;
    final button = TextButton(
      onPressed: onPressed,
      style: _style(effective),
      child: Text(label.toUpperCase(), textAlign: TextAlign.center),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
