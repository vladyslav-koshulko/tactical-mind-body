import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../button/tmb_button.dart';
import '../phase/tmb_phase_theme.dart';

/// Крупная собственная цифровая клавиатура когнитивной паузы.
///
/// Системной клавиатурой в мокрые дрожащие пальцы не попасть (DESIGN.md,
/// экран 03), поэтому клавиши высотой [TmbSize.keypadKey] с зазорами
/// [TmbSpace.x2]. Раскладка постоянна, чтобы работала мышечная память:
///
/// ```
///  1  2  3
///  4  5  6
///  7  8  9
///  −  0  ,      // минус и запятая — только если переданы колбэки
///  ⌫  [ОК    ]  // стереть и подтвердить
/// ```
///
/// Кнопка подтверждения — единственная primary на экране паузы, поэтому
/// красится в цвет фазы. Тексты (`backspaceLabel`, `submitLabel` и т. д.)
/// приходят параметрами из ARB; сама клавиатура не содержит слов.
class TmbNumericKeypad extends StatelessWidget {
  const TmbNumericKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    required this.backspaceLabel,
    required this.submitLabel,
    this.onMinus,
    this.onDecimal,
    this.minusLabel,
    this.decimalLabel,
    this.decimalSeparator = defaultDecimalSeparator,
    this.phase,
    super.key,
  }) : assert(
         onMinus == null || minusLabel != null,
         'minusLabel нужен для скринридера, если есть onMinus',
       ),
       assert(
         onDecimal == null || decimalLabel != null,
         'decimalLabel нужен для скринридера, если есть onDecimal',
       );

  /// Знак на клавише минуса (математический минус, не дефис).
  static const minusSign = '−';

  /// Разделитель по умолчанию; для локалей с точкой его задаёт вызывающий.
  static const defaultDecimalSeparator = ',';

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  /// `null` — подтверждение недоступно (например, поле пустое).
  final VoidCallback? onSubmit;

  /// Если задан — слева в нижнем ряду появляется минус.
  final VoidCallback? onMinus;

  /// Если задан — справа в нижнем ряду появляется запятая.
  final VoidCallback? onDecimal;

  final String backspaceLabel;
  final String submitLabel;
  final String? minusLabel;
  final String? decimalLabel;
  final String decimalSeparator;

  /// `null` — наследовать фазу из темы (на экране паузы — когнитивная).
  final TmbPhase? phase;

  static const _gap = TmbSpace.x2;

  @override
  Widget build(BuildContext context) {
    final effective = phase ?? TmbPhaseTheme.of(context).phase;

    Widget digit(int d) => Expanded(
      child: _Key(
        phase: effective,
        onPressed: () => onDigit(d),
        child: Text('$d', style: TmbType.dataMetric),
      ),
    );

    Widget row(List<Widget> keys) => Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          keys[i],
        ],
      ],
    );

    const blank = Expanded(child: SizedBox.shrink());

    final minus = onMinus == null
        ? blank
        : Expanded(
            child: _Key(
              phase: effective,
              onPressed: onMinus,
              semanticLabel: minusLabel,
              child: const Text(minusSign, style: TmbType.dataMetric),
            ),
          );
    final decimal = onDecimal == null
        ? blank
        : Expanded(
            child: _Key(
              phase: effective,
              onPressed: onDecimal,
              semanticLabel: decimalLabel,
              child: Text(decimalSeparator, style: TmbType.dataMetric),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([digit(1), digit(2), digit(3)]),
        const SizedBox(height: _gap),
        row([digit(4), digit(5), digit(6)]),
        const SizedBox(height: _gap),
        row([digit(7), digit(8), digit(9)]),
        const SizedBox(height: _gap),
        row([minus, digit(0), decimal]),
        const SizedBox(height: _gap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Key(
                  phase: effective,
                  onPressed: onBackspace,
                  semanticLabel: backspaceLabel,
                  child: const Icon(
                    Icons.backspace_outlined,
                    size: TmbSize.icon,
                  ),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                flex: 2,
                child: TmbButton(
                  label: submitLabel,
                  onPressed: onSubmit,
                  phase: effective,
                  expand: true,
                  minHeight: TmbSize.keypadKey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Клавиша: не меньше [TmbSize.keypadKey] по обеим осям.
class _Key extends StatelessWidget {
  const _Key({
    required this.phase,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
  });

  final TmbPhase phase;
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.pressed) ? phase.surface : TmbColor.raised,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.pressed)
            ? phase.accent
            : TmbColor.textPrimary,
      ),
      side: WidgetStateProperty.resolveWith(
        (s) => BorderSide(
          color:
              s.contains(WidgetState.pressed) || s.contains(WidgetState.focused)
              ? phase.accent
              : TmbColor.borderDefault,
          width: TmbStroke.base,
        ),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(Size.square(TmbSize.keypadKey)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
        ),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
    final button = TextButton(onPressed: onPressed, style: style, child: child);
    return semanticLabel == null
        ? button
        : Semantics(
            label: semanticLabel,
            button: true,
            excludeSemantics: true,
            onTap: onPressed,
            child: button,
          );
  }
}
