import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_mobile/dashboard/dashboard_screen.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

import 'features/settings/settings_test_support.dart' show unmountApp;
import 'helpers.dart';

final _l10n = AppLocalizationsRu();

void main() {
  testWidgets('пока контент грузится — экран загрузки, навигатор не строится', (
    tester,
  ) async {
    addTearDown(() => unmountApp(tester));
    final pending = Completer<BuiltinContent>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(),
          contentProvider.overrideWith((ref) => pending.future),
        ],
        child: const TmbApp(),
      ),
    );
    await tester.pump();

    expect(find.text(_l10n.appLoading.toUpperCase()), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);

    pending.complete(const BuiltinContent(taskPacks: [], exercisePacks: []));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('ошибка загрузки — экран ошибки с повтором', (tester) async {
    addTearDown(() => unmountApp(tester));
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(),
          contentProvider.overrideWith((ref) async {
            attempts++;
            if (attempts == 1) throw const ContentLoadException('сломан пак');
            return const BuiltinContent(taskPacks: [], exercisePacks: []);
          }),
        ],
        child: const TmbApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.appLoadErrorTitle.toUpperCase()), findsOneWidget);
    expect(find.textContaining('сломан пак'), findsOneWidget);

    await tester.tap(find.text(_l10n.appRetry.toUpperCase()));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(attempts, 2);
  });
}
