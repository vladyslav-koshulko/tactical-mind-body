import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Панель с заголовком: группа связанных настроек (панель графита с тонкой
/// рамкой, как «последняя операция» на дашборде).
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({
    required this.heading,
    required this.children,
    this.hint,
    super.key,
  });

  final String heading;

  /// Пояснение под заголовком.
  final String? hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TmbSpace.x4),
      child: Container(
        padding: const EdgeInsets.all(TmbSpace.x4),
        decoration: BoxDecoration(
          color: TmbColor.surface,
          borderRadius: BorderRadius.circular(TmbRadius.sharp),
          border: Border.all(color: TmbColor.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                heading.toUpperCase(),
                style: TmbType.labelLg.copyWith(color: TmbColor.textPrimary),
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: TmbSpace.x2),
              Text(
                hint!,
                style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
              ),
            ],
            const SizedBox(height: TmbSpace.x3),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Сообщение о состоянии экрана: загрузка, ошибка, пустой список.
///
/// Ошибка выделяется значком и текстом, а не только цветом.
class StatusMessage extends StatelessWidget {
  const StatusMessage.loading(this.text, {super.key}) : isError = false;
  const StatusMessage.error(this.text, {super.key}) : isError = true;
  const StatusMessage.info(this.text, {super.key}) : isError = false;

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? TmbColor.danger : TmbColor.textSecondary;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(TmbSpace.x4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isError) ...[
              Icon(Icons.error_outline, size: TmbSize.icon, color: color),
              const SizedBox(width: TmbSpace.x2),
            ],
            Expanded(
              child: Text(text, style: TmbType.bodyMd.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
