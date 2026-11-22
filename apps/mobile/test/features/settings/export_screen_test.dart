import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/features/settings/events_file.dart';
import 'package:tmb_mobile/features/settings/export_screen.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

import '../../helpers.dart';
import 'settings_test_support.dart';

final _l10n = AppLocalizationsRu();

final _fileName = RegExp(
  r'^tactical-mind-body-events-\d{4}-\d{2}-\d{2}\.json$',
);

void main() {
  group('EventsFile', () {
    test('имя по дате, содержимое — валидный events_export', () {
      final export = EventsExport(
        sessions: [
          const Session(
            id: '62ed4258-a855-4484-9598-d5cc938f60f0',
            startedAt: 1795100000000,
            endedAt: 1795101500000,
            utcOffsetMin: 180,
            location: Location.home,
            difficulty: DifficultyLevel.fighter,
            template: SessionTemplateKind.dualTask,
            appVersion: '0.1.0+1',
          ),
        ],
      );
      final file = EventsFile.from(export, nowMs: fakeNowMs);
      expect(file.fileName, matches(_fileName));
      expect(
        jsonDecode(utf8.decode(file.bytes)),
        containsPair('kind', 'events_export'),
      );
    });
  });

  group('экран экспорта', () {
    testWidgets('данных нет: понятное состояние, кнопка выключена', (
      tester,
    ) async {
      final fake = FakeFileShareService();
      await pumpScreen(
        tester,
        const ExportScreen(),
        overrides: [shareOverride(fake)],
      );

      expect(find.text(_l10n.exportEmpty), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(fake.shared, isEmpty);
    });

    testWidgets('сводка и валидный JSON уходят в «Поделиться»', (tester) async {
      final fake = FakeFileShareService();
      final c = await pumpScreen(
        tester,
        const ExportScreen(),
        overrides: [shareOverride(fake)],
      );
      final seeded = await seedSampleSession(tester, c);
      c.invalidate(eventsExportProvider);
      await settle(tester);

      expect(
        find.text(
          _l10n.exportCounts(
            seeded.sessions.length,
            seeded.rounds.length,
            seeded.sets.length,
            seeded.attempts.length,
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(_l10n.exportButton.toUpperCase()));
      await settle(tester);

      expect(fake.shared, hasLength(1));
      final file = fake.shared.single;
      expect(file.fileName, matches(_fileName));
      expect(file.mimeType, 'application/json');

      // Файл проходит доменный валидатор без единой ошибки (и без замечаний).
      final result = validate(
        file.bytes,
        const ValidationContext(expectedKind: DocumentKind.eventsExport),
      );
      expect(result.isDocumentRejected, isFalse);
      expect(result.errorCount, 0, reason: result.errors.join('\n'));
      final parsed = result.eventsExport!;
      expect(parsed.sessions.single.id, seeded.sessions.single.id);
      expect(parsed.attempts, hasLength(seeded.attempts.length));
      expect(parsed.sets, hasLength(seeded.sets.length));
      expect(parsed.rounds, hasLength(seeded.rounds.length));
    });

    testWidgets('сбой «Поделиться» показан, кнопка снова доступна', (
      tester,
    ) async {
      final fake = FakeFileShareService()..failWith = StateError('нет плагина');
      final c = await pumpScreen(
        tester,
        const ExportScreen(),
        overrides: [shareOverride(fake)],
      );
      await seedSampleSession(tester, c);
      c.invalidate(eventsExportProvider);
      await settle(tester);

      await tester.tap(find.text(_l10n.exportButton.toUpperCase()));
      await settle(tester);

      expect(find.text(_l10n.exportError), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('320 px, textScale 1.5: без overflow', (tester) async {
      final c = await pumpScreen(
        tester,
        const ExportScreen(),
        width: narrowLogicalWidth,
        textScale: bigTextScale,
      );
      expect(tester.takeException(), isNull);
      await seedSampleSession(tester, c);
      c.invalidate(eventsExportProvider);
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
