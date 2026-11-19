import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Статичная плитка локации (экран №01). Логики выбора пока нет.
///
/// «Выбрано» передаётся НЕ только цветом: утолщённая рамка, галочка и
/// текстовая метка [selectedLabel].
class LocationTile extends StatelessWidget {
  const LocationTile({
    required this.index,
    required this.name,
    required this.selectedLabel,
    this.selected = false,
    super.key,
  });

  /// Типографический индекс «01» (иконок локаций в дизайне пока нет).
  final String index;
  final String name;
  final String selectedLabel;
  final bool selected;

  /// Толщина рамки выбранной плитки. Токена толщины нет — половина x1 (= 2 px).
  static const double _selectedBorderWidth = TmbSpace.x1 / 2;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? const BorderSide(
            color: TmbColor.accent500,
            width: _selectedBorderWidth,
          )
        : const BorderSide(color: TmbColor.borderDefault);

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: Container(
          constraints: const BoxConstraints(minHeight: TmbSpace.x12 * 2),
          padding: const EdgeInsets.all(TmbSpace.x3),
          decoration: BoxDecoration(
            color: selected ? TmbColor.accent900 : TmbColor.surface,
            borderRadius: BorderRadius.circular(TmbRadius.sharp),
            border: Border.fromBorderSide(border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                index,
                style: TmbType.dataMono.copyWith(
                  color: selected ? TmbColor.accent500 : TmbColor.textSecondary,
                ),
              ),
              const SizedBox(height: TmbSpace.x2),
              Text(
                name.toUpperCase(),
                style: TmbType.labelLg.copyWith(color: TmbColor.textPrimary),
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
            ],
          ),
        ),
      ),
    );
  }
}
