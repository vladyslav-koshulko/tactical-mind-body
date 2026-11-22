import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Строка-ссылка на вложенный экран: заголовок, краткая сводка, шеврон.
class LinkRow extends StatelessWidget {
  const LinkRow({
    required this.title,
    required this.onTap,
    this.summary,
    super.key,
  });

  final String title;
  final String? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: summary == null ? title : '$title. $summary',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TmbTheme.minTapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TmbSpace.x2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: TmbType.labelMd.copyWith(
                          color: TmbColor.textPrimary,
                        ),
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: TmbSpace.x1),
                        Text(
                          summary!,
                          style: TmbType.bodySm.copyWith(
                            color: TmbColor.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: TmbSpace.x2),
                const Icon(
                  Icons.chevron_right,
                  size: TmbSize.icon,
                  color: TmbColor.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
