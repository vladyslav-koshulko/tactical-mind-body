import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';

/// Крупная плитка одиночного выбора — основа [TmbSelfRatingBar] и
/// [TmbEffortPicker]. Внутренняя: наружу не экспортируется.
///
/// Выбранность передаётся не только цветом (инвариант 6): заливка + галочка.
class TmbChoiceTile extends StatelessWidget {
  const TmbChoiceTile({
    required this.title,
    required this.titleStyle,
    required this.selected,
    required this.onPressed,
    required this.phase,
    this.caption,
    super.key,
  });

  final String title;
  final TextStyle titleStyle;
  final String? caption;
  final bool selected;
  final VoidCallback onPressed;
  final TmbPhase phase;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (selected) return phase.accent;
        return s.contains(WidgetState.pressed)
            ? phase.surface
            : TmbColor.raised;
      }),
      foregroundColor: WidgetStatePropertyAll(
        selected ? TmbColor.textInverse : TmbColor.textPrimary,
      ),
      side: WidgetStateProperty.resolveWith(
        (s) => BorderSide(
          color: selected || s.contains(WidgetState.pressed)
              ? phase.accent
              : TmbColor.borderDefault,
          width: TmbStroke.base,
        ),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(
        Size(TmbSize.tapTarget, TmbSize.keypadKey),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: TmbSpace.x2, vertical: TmbSpace.x2),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
        ),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      label: caption == null ? title : '$title, $caption',
      excludeSemantics: true,
      onTap: onPressed,
      child: TextButton(
        onPressed: onPressed,
        style: style,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(Icons.check, size: TmbSize.icon),
                  const SizedBox(width: TmbSpace.x1),
                ],
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                ),
              ],
            ),
            if (caption != null) ...[
              const SizedBox(height: TmbSpace.x1),
              Text(
                caption!.toUpperCase(),
                textAlign: TextAlign.center,
                style: TmbType.labelSm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
