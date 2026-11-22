import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/dashboard/dashboard_screen.dart';
import 'package:tmb_mobile/features/session/session_screen.dart';
import 'package:tmb_mobile/features/session/session_summary_screen.dart';
import 'package:tmb_mobile/features/settings/categories_screen.dart';
import 'package:tmb_mobile/features/settings/settings_screen.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

import 'features/settings/settings_test_support.dart' show unmountApp;
import 'helpers.dart';

final _l10n = AppLocalizationsRu();

Future<GoRouter> _pump(
  WidgetTester tester, {
  String initialLocation = TmbRoutes.home,
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  addTearDown(() => unmountApp(tester));
  final router = createRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(),
        routerProvider.overrideWithValue(router),
        ...extra,
      ],
      child: const TmbApp(),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('маршруты рендерят экраны', () {
    final cases = <String, (Type, String)>{
      TmbRoutes.home: (DashboardScreen, ''),
      TmbRoutes.session: (SessionScreen, ''),
      TmbRoutes.summaryOf('abc-123'): (SessionSummaryScreen, 'abc-123'),
      TmbRoutes.settings: (SettingsScreen, ''),
      TmbRoutes.categories: (CategoriesScreen, ''),
    };
    for (final entry in cases.entries) {
      testWidgets(entry.key, (tester) async {
        await _pump(tester, initialLocation: entry.key);
        expect(find.byType(entry.value.$1), findsOneWidget);
        if (entry.value.$2.isNotEmpty) {
          expect(find.textContaining(entry.value.$2), findsOneWidget);
        }
      });
    }
  });

  testWidgets('sessionId из пути доходит до экрана итогов', (tester) async {
    await _pump(tester, initialLocation: TmbRoutes.summaryOf('a b/с'));
    final screen = tester.widget<SessionSummaryScreen>(
      find.byType(SessionSummaryScreen),
    );
    expect(screen.sessionId, 'a b/с');
  });

  testWidgets(
    'дашборд: «Начать операцию» ведёт на /session, назад возвращает',
    (tester) async {
      final router = await _pump(tester);
      await tester.tap(find.text(_l10n.startOperation.toUpperCase()));
      await tester.pumpAndSettle();
      expect(find.byType(SessionScreen), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    },
  );

  testWidgets('дашборд: шестерёнка ведёт на /settings', (tester) async {
    await _pump(tester);
    await tester.tap(find.byTooltip(_l10n.dashboardSettings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('/settings/categories вложен в /settings: назад — в настройки', (
    tester,
  ) async {
    final router = await _pump(tester, initialLocation: TmbRoutes.settings);
    unawaited(router.push(TmbRoutes.categories));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesScreen), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('неизвестный маршрут — экран «не найден» и выход на дашборд', (
    tester,
  ) async {
    await _pump(tester, initialLocation: '/нет-такого');
    expect(
      find.text(_l10n.appRouteNotFoundTitle.toUpperCase()),
      findsOneWidget,
    );
    await tester.tap(find.text(_l10n.appBackToDashboard.toUpperCase()));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
