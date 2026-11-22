import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/dashboard/dashboard_screen.dart';
import 'package:tmb_mobile/dashboard/location_tile.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/session/session_summary_screen.dart';
import 'package:tmb_mobile/features/settings/widgets/selectable_tile.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';
import 'package:tmb_mobile/l10n/app_localizations_uk.dart';

import 'features/settings/settings_test_support.dart';

final _l10n = AppLocalizationsRu();

Future<SessionPreferences> _prefs(WidgetTester tester, ProviderContainer c) =>
    db(
      tester,
      () => c.read(profileRepositoryProvider).loadSessionPreferences(),
    );

/// Подпись выбранной плитки сложности (радио-значок «заполнен»).
String _selectedDifficulty(WidgetTester tester) {
  final tile = find.ancestor(
    of: find.byIcon(Icons.radio_button_checked),
    matching: find.byType(SelectableTile),
  );
  expect(tile, findsOneWidget);
  return tester.widget<SelectableTile>(tile).label;
}

void main() {
  group('дашборд: локация', () {
    testWidgets('«Дом» выбрана, остальные честно помечены «скоро»', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.byType(LocationTile), findsNWidgets(3));
      expect(find.text(_l10n.locationSelected.toUpperCase()), findsOneWidget);
      // «Скоро» — текст и значок, а не только приглушённый цвет.
      expect(
        find.text(_l10n.dashboardLocationSoon.toUpperCase()),
        findsNWidgets(2),
      );
      expect(find.byIcon(Icons.schedule), findsNWidgets(2));
    });

    testWidgets('недоступная локация не выбирается', (tester) async {
      final c = await pumpApp(tester);
      await tester.tap(find.text(_l10n.locationGym.toUpperCase()));
      await settle(tester);
      await tester.tap(find.text(_l10n.locationStreet.toUpperCase()));
      await settle(tester);

      expect((await _prefs(tester, c)).location, Location.home);
      expect(find.text(_l10n.locationSelected.toUpperCase()), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('«Дом» выбирается и сохраняется', (tester) async {
      final c = await pumpApp(tester);
      await tester.tap(find.text(_l10n.locationHome.toUpperCase()));
      await settle(tester);
      expect((await _prefs(tester, c)).location, Location.home);
    });

    testWidgets('недоступная локация из БД приводится к «Дому»', (
      tester,
    ) async {
      final c = await pumpApp(tester);
      await db(
        tester,
        () => c
            .read(profileRepositoryProvider)
            .saveSessionPreferences(
              SessionPreferences.standard.copyWith(location: Location.gym),
            ),
      );
      await settle(tester);
      expect((await _prefs(tester, c)).location, Location.home);
    });
  });

  group('дашборд: сложность', () {
    testWidgets('по умолчанию «Рекрут»; выбор сохраняется сразу', (
      tester,
    ) async {
      final c = await pumpApp(tester);
      expect(_selectedDifficulty(tester), _l10n.dashboardDifficultyRecruit);

      await tester.tap(
        find.text(_l10n.dashboardDifficultyOperator.toUpperCase()),
      );
      await settle(tester);

      expect((await _prefs(tester, c)).difficulty, DifficultyLevel.operator);
      expect(_selectedDifficulty(tester), _l10n.dashboardDifficultyOperator);
    });

    testWidgets('сохранённый выбор читается при открытии', (tester) async {
      final c = await pumpApp(tester);
      await db(
        tester,
        () => c
            .read(profileRepositoryProvider)
            .saveSessionPreferences(
              SessionPreferences.standard.copyWith(
                difficulty: DifficultyLevel.spetsnaz,
              ),
            ),
      );
      await settle(tester);
      expect(_selectedDifficulty(tester), _l10n.dashboardDifficultySpetsnaz);
    });
  });

  group('дашборд: последняя операция', () {
    testWidgets('сессий нет — «пока нет данных»', (tester) async {
      await pumpApp(tester);
      expect(find.text(_l10n.lastOperationEmpty), findsOneWidget);
      expect(
        find.text(_l10n.dashboardLastOperationDone.toUpperCase()),
        findsNothing,
      );
    });

    testWidgets('по последней сессии из БД: завершена, круги и задачи', (
      tester,
    ) async {
      final c = await pumpApp(tester);
      final export = await seedSampleSession(tester, c);
      await settle(tester);

      expect(find.text(_l10n.lastOperationEmpty), findsNothing);
      expect(
        find.text(_l10n.dashboardLastOperationDone.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          _l10n.dashboardLastOperationRounds(export.rounds.length),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          _l10n.dashboardLastOperationTasks(export.attempts.length),
        ),
        findsOneWidget,
      );
      // Шаблон, сложность и локация сессии — по её собственным полям.
      expect(
        find.textContaining(_l10n.dashboardDifficultyFighter),
        findsWidgets,
      );
    });

    testWidgets('прерванная сессия помечена «прервана»', (tester) async {
      final c = await pumpApp(tester);
      await seedSampleSession(tester, c, interrupted: true);
      await settle(tester);
      expect(
        find.text(_l10n.dashboardLastOperationInterrupted.toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('нажатие ведёт на итог этой сессии', (tester) async {
      final c = await pumpApp(tester);
      final export = await seedSampleSession(tester, c);
      await settle(tester);

      final details = find.text(
        _l10n.dashboardLastOperationDetails.toUpperCase(),
      );
      await tester.ensureVisible(details);
      await tester.pumpAndSettle();
      await tester.tap(details);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final screen = tester.widget<SessionSummaryScreen>(
        find.byType(SessionSummaryScreen),
      );
      expect(screen.sessionId, export.sessions.single.id);
    });
  });

  group('дашборд: вёрстка', () {
    for (final entry in {
      const Locale('ru'): 'ru',
      const Locale('uk'): 'uk',
    }.entries) {
      testWidgets('${entry.value}: 320 px, textScale 1.5 — без overflow', (
        tester,
      ) async {
        final c = await pumpApp(
          tester,
          locale: entry.key,
          width: narrowLogicalWidth,
          textScale: bigTextScale,
        );
        expect(tester.takeException(), isNull);
        await seedSampleSession(tester, c);
        await settle(tester);
        expect(tester.takeException(), isNull);
        for (var i = 0; i < 6; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('uk: подписи сложности и «скоро» на украинском', (
      tester,
    ) async {
      await pumpApp(tester, locale: const Locale('uk'));
      final uk = AppLocalizationsUk();
      expect(
        find.text(uk.dashboardDifficultySpetsnaz.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(uk.dashboardLocationSoon.toUpperCase()),
        findsNWidgets(2),
      );
    });
  });
}
