import 'package:flutter/foundation.dart' show LicenseRegistry;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_mobile/features/settings/about_screen.dart';
import 'package:tmb_mobile/features/settings/app_info.dart';
import 'package:tmb_mobile/features/settings/font_licenses.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

import 'settings_test_support.dart';

final _l10n = AppLocalizationsRu();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('тексты OFL лежат в ассетах и читаются', () async {
    for (final path in fontLicenseAssets.values) {
      final text = await rootBundle.loadString(path);
      expect(text, contains('SIL OPEN FONT LICENSE'), reason: path);
    }
  });

  test('registerFontLicenses кладёт обе лицензии в LicenseRegistry', () async {
    registerFontLicenses(rootBundle);
    registerFontLicenses(rootBundle); // идемпотентно

    final byPackage = <String, int>{};
    await for (final entry in LicenseRegistry.licenses) {
      for (final package in entry.packages) {
        byPackage[package] = (byPackage[package] ?? 0) + 1;
        if (fontLicenseAssets.containsKey(package)) {
          final text = entry.paragraphs.map((p) => p.text).join('\n');
          expect(text, contains('SIL OPEN FONT LICENSE'));
        }
      }
    }
    expect(byPackage['Oswald'], 1);
    expect(byPackage['JetBrains Mono'], 1);
  });

  group('экран «О приложении»', () {
    testWidgets('версия, описание, лицензии', (tester) async {
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(_l10n.aboutVersion(appVersion)), findsOneWidget);
      expect(find.text(_l10n.aboutFonts), findsOneWidget);
    });

    testWidgets('«Лицензии» открывают стандартную страницу лицензий', (
      tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      await tester.tap(find.text(_l10n.aboutLicenses.toUpperCase()).last);
      // Страница собирает лицензии настоящими `Future` — вне фейковых часов.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LicensePage), findsOneWidget);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      // В списке пакетов — оба шрифта (если страница успела собрать записи).
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 px, textScale 1.5: без overflow', (tester) async {
      await pumpScreen(
        tester,
        const AboutScreen(),
        width: narrowLogicalWidth,
        textScale: bigTextScale,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
