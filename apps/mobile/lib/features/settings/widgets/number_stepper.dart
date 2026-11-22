import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Числовое поле «− значение +» с вводом по нажатию на значение.
///
/// Кнопки — цели касания 48 (DESIGN.md, правило 4). Значение всегда в пределах
/// [min]…[max]: за границей кнопка выключена, ввод с клавиатуры проверяется
/// и показывает допустимый диапазон.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.format,
    super.key,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  /// Как показывать значение («180 с»); по умолчанию — число.
  final String Function(int value)? format;

  String _text(int v) => format?.call(v) ?? '$v';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
        ),
        const SizedBox(height: TmbSpace.x2),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove,
              tooltip: l10n.settingsStepperDecrease(label),
              onPressed: value > min
                  ? () => onChanged((value - step).clamp(min, max))
                  : null,
            ),
            const SizedBox(width: TmbSpace.x2),
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.settingsStepperEdit(label),
                value: _text(value),
                excludeSemantics: true,
                onTap: () => _edit(context),
                child: Material(
                  color: TmbColor.raised,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TmbRadius.sharp),
                    side: const BorderSide(color: TmbColor.borderDefault),
                  ),
                  child: InkWell(
                    onTap: () => _edit(context),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: TmbTheme.minTapTarget,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TmbSpace.x2,
                          ),
                          child: Text(
                            _text(value),
                            textAlign: TextAlign.center,
                            style: TmbType.dataMetric.copyWith(
                              color: TmbColor.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: TmbSpace.x2),
            _StepButton(
              icon: Icons.add,
              tooltip: l10n.settingsStepperIncrease(label),
              onPressed: value < max
                  ? () => onChanged((value + step).clamp(min, max))
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) =>
          _ValueDialog(label: label, value: value, min: min, max: max),
    );
    if (result != null && result != value) onChanged(result);
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(
        minWidth: TmbTheme.minTapTarget,
        minHeight: TmbTheme.minTapTarget,
      ),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TmbRadius.sharp),
        ),
        side: BorderSide(
          color: onPressed == null
              ? TmbColor.borderSubtle
              : TmbColor.borderDefault,
        ),
      ),
      icon: Icon(icon, size: TmbSize.icon),
    );
  }
}

class _ValueDialog extends StatefulWidget {
  const _ValueDialog({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
  });

  final String label;
  final int value;
  final int min;
  final int max;

  @override
  State<_ValueDialog> createState() => _ValueDialogState();
}

class _ValueDialogState extends State<_ValueDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.value}',
  );
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < widget.min || parsed > widget.max) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: TmbColor.overlay,
      title: Text(
        l10n.settingsStepperEdit(widget.label).toUpperCase(),
        style: TmbType.labelLg.copyWith(color: TmbColor.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        style: TmbType.dataMetric.copyWith(color: TmbColor.textPrimary),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          errorText: _invalid
              ? l10n.settingsStepperRangeError(widget.min, widget.max)
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.settingsCancel.toUpperCase()),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.settingsConfirm.toUpperCase()),
        ),
      ],
    );
  }
}
