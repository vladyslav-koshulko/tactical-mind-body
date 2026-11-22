import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Вариант выбора (радио-плитка): шаблон операции, режим повторений, сложность.
///
/// «Выбрано» передаётся не только цветом: утолщённая рамка и значок
/// «радио» (заполненный/пустой) — форма читается и без цвета.
class SelectableTile extends StatelessWidget {
  const SelectableTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.hint,
    super.key,
  });

  final String label;
  final String? hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? TmbColor.accent500 : TmbColor.borderDefault;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label,
      hint: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? TmbColor.accent900 : TmbColor.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TmbRadius.sharp),
          side: BorderSide(
            color: borderColor,
            width: selected ? TmbStroke.base : TmbStroke.thin,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TmbTheme.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TmbSpace.x3,
                vertical: TmbSpace.x2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: TmbSize.icon,
                    color: selected
                        ? TmbColor.accent500
                        : TmbColor.textSecondary,
                  ),
                  const SizedBox(width: TmbSpace.x3),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: TmbType.labelMd.copyWith(
                            color: TmbColor.textPrimary,
                          ),
                        ),
                        if (hint != null) ...[
                          const SizedBox(height: TmbSpace.x1),
                          Text(
                            hint!,
                            style: TmbType.bodySm.copyWith(
                              color: TmbColor.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
