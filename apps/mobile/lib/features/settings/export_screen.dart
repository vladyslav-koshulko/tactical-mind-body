import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'events_file.dart';
import 'settings_providers.dart';
import 'widgets/settings_page.dart';
import 'widgets/settings_panel.dart';

/// Сводка событий для экрана экспорта. Перечитывается при каждом открытии.
final eventsExportProvider = FutureProvider.autoDispose<EventsExport>(
  (ref) => ref.watch(sessionRepositoryProvider).exportEvents(),
);

/// Экран «Экспорт данных» (R6, v0.1): все сырые события одним JSON-файлом
/// `tactical-mind-body-events-<дата>.json` через системное «Поделиться».
///
/// Файл готовится из БД заново в момент нажатия, а не из показанной сводки.
/// Открывается через `Navigator.push` из настроек (маршрута в роутере нет).
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _share() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final export = await ref.read(sessionRepositoryProvider).exportEvents();
      if (isEventsExportEmpty(export)) {
        ref.invalidate(eventsExportProvider);
        return;
      }
      final file = EventsFile.from(export, nowMs: ref.read(clockProvider)());
      await ref
          .read(fileShareServiceProvider)
          .shareFile(
            fileName: file.fileName,
            bytes: file.bytes,
            mimeType: eventsFileMimeType,
          );
    } on Object {
      _failed = true;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final events = ref.watch(eventsExportProvider);

    final export = events.value;
    final empty = export != null && isEventsExportEmpty(export);

    return SettingsPage(
      title: l10n.exportTitle,
      children: [
        SettingsPanel(
          heading: l10n.settingsLinkExport,
          hint: l10n.exportDescription,
          children: [
            if (events.hasError)
              StatusMessage.error(l10n.exportLoadError)
            else if (export == null)
              StatusMessage.loading(l10n.exportPreparing)
            else if (empty)
              StatusMessage.info(l10n.exportEmpty)
            else
              Text(
                l10n.exportCounts(
                  export.sessions.length,
                  export.rounds.length,
                  export.sets.length,
                  export.attempts.length,
                ),
                style: TmbType.dataMono.copyWith(color: TmbColor.textPrimary),
              ),
            const SizedBox(height: TmbSpace.x3),
            Text(
              l10n.exportPrivacy,
              style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
            ),
            if (_failed) ...[
              const SizedBox(height: TmbSpace.x3),
              StatusMessage.error(l10n.exportError),
            ],
            const SizedBox(height: TmbSpace.x4),
            // Единственная Primary-кнопка экрана (DESIGN.md, правило 1).
            FilledButton(
              onPressed: (export == null || empty || _busy) ? null : _share,
              child: Text(
                (_busy ? l10n.exportPreparing : l10n.exportButton)
                    .toUpperCase(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
