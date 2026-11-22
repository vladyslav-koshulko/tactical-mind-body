import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Плитка локации (экран №01).
///
/// «Выбрано» передаётся НЕ только цветом: утолщённая рамка, галочка и
/// текстовая метка [selectedLabel]. «Недоступно в этой версии»
/// ([soonLabel] задан) — приглушённая рамка, значок часов и текст: плитка не
/// нажимается и не притворяется рабочей.
class LocationTile extends StatelessWidget {
  const LocationTile({
    required this.index,
    required this.name,
    required this.selectedLabel,
    this.selected = false,
    this.onTap,
    this.soonLabel,
    super.key,
  });

  /// Типографический индекс «01» (иконок локаций в дизайне пока нет).
  final String index;
  final String name;
  final String selectedLabel;
  final bool selected;

  /// Нажатие. Для недоступной плитки игнорируется.
  final VoidCallback? onTap;

  /// Метка «Скоро»; не `null` — плитка недоступна.
  final String? soonLabel;

  bool get _available => soonLabel == null;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? const BorderSide(color: TmbColor.accent500, width: TmbStroke.base)
        : BorderSide(
            color: _available ? TmbColor.borderDefault : TmbColor.borderSubtle,
          );
    final tap = _available ? onTap : null;

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        button: true,
        enabled: _available,
        child: Material(
          color: selected ? TmbColor.accent900 : TmbColor.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TmbRadius.sharp),
            side: border,
          ),
          child: InkWell(
            onTap: tap,
            child: Container(
              constraints: const BoxConstraints(minHeight: TmbSpace.x12 * 2),
              padding: const EdgeInsets.all(TmbSpace.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    index,
                    style: TmbType.dataMono.copyWith(
                      color: selected
                          ? TmbColor.accent500
                          : TmbColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: TmbSpace.x2),
                  Text(
                    name.toUpperCase(),
                    style: TmbType.labelLg.copyWith(
                      color: _available
                          ? TmbColor.textPrimary
                          : TmbColor.textSecondary,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: TmbSpace.x2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: TmbSpace.x1,
                      children: [
                        const Icon(
                          Icons.check,
                          size: TmbSpace.x4,
                          color: TmbColor.accent500,
                        ),
                        Text(
                          selectedLabel.toUpperCase(),
                          style: TmbType.labelSm.copyWith(
                            color: TmbColor.accent500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!_available) ...[
                    const SizedBox(height: TmbSpace.x2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: TmbSpace.x1,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: TmbSpace.x4,
                          color: TmbColor.textSecondary,
                        ),
                        Text(
                          soonLabel!.toUpperCase(),
                          style: TmbType.labelSm.copyWith(
                            color: TmbColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
