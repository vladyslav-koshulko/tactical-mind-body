import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Строка с переключателем. Состояние дублируется текстом «Вкл/Выкл» —
/// положение бегунка не единственный канал.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onLabel,
    required this.offLabel,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String onLabel;
  final String offLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      value: value ? onLabel : offLabel,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TmbTheme.minTapTarget),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TmbType.labelMd.copyWith(color: TmbColor.textPrimary),
                ),
              ),
              const SizedBox(width: TmbSpace.x2),
              Text(
                (value ? onLabel : offLabel).toUpperCase(),
                style: TmbType.labelSm.copyWith(
                  color: value ? TmbColor.accent500 : TmbColor.textSecondary,
                ),
              ),
              const SizedBox(width: TmbSpace.x2),
              ExcludeSemantics(
                child: Switch(value: value, onChanged: onChanged),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
