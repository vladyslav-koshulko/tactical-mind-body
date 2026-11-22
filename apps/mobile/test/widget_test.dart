import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_mobile/dashboard/location_tile.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';
import 'package:tmb_mobile/l10n/app_localizations_uk.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'features/settings/settings_test_support.dart' show unmountApp;
import 'helpers.dart';

final _ukLetters = RegExp('[іїєґ]');

Future<void> _pump(WidgetTester tester, Locale locale) async {
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  addTearDown(() => unmountApp(tester));
  await tester.pumpWidget(
    ProviderScope(
      overrides: testOverrides(),
      child: TmbApp(locale: locale),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('дашборд', () {
    for (final entry in {
      const Locale('ru'): AppLocalizationsRu(),
      const Locale('uk'): AppLocalizationsUk(),
    }.entries) {
      final l10n = entry.value;
      testWidgets('${entry.key}: заголовок, три плитки, одна Primary', (
        tester,
      ) async {
        await _pump(tester, entry.key);

        expect(find.text(l10n.dashboardTitle.toUpperCase()), findsOneWidget);
        expect(find.byType(LocationTile), findsNWidgets(3));
        expect(find.text(l10n.locationHome.toUpperCase()), findsOneWidget);
        expect(find.text(l10n.locationGym.toUpperCase()), findsOneWidget);
        expect(find.text(l10n.locationStreet.toUpperCase()), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.text(l10n.startOperation.toUpperCase()), findsOneWidget);
        expect(find.text(l10n.lastOperationEmpty), findsOneWidget);
        // Выбрана ровно одна плитка, и это видно по тексту, а не только цвету.
        expect(find.text(l10n.locationSelected.toUpperCase()), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    }

    testWidgets('uk: на экране есть буквы і/ї/є/ґ', (tester) async {
      await _pump(tester, const Locale('uk'));

      final texts = tester.widgetList<Text>(find.byType(Text));
      expect(
        texts.any((t) => _ukLetters.hasMatch((t.data ?? '').toLowerCase())),
        isTrue,
      );
    });

    test('uk ARB содержит і/ї/є/ґ, а ru-строки не подменяют uk', () {
      final arb = jsonDecode(
        File('lib/l10n/app_uk.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final values = arb.entries
          .where((e) => !e.key.startsWith('@'))
          .map((e) => e.value as String);
      expect(values.any(_ukLetters.hasMatch), isTrue);
      expect(
        AppLocalizationsUk().locationHome,
        isNot(AppLocalizationsRu().locationHome),
      );
    });

    testWidgets('ни одна интерактивная цель не ниже 48', (tester) async {
      await _pump(tester, const Locale('ru'));

      final targets = find.byWidgetPredicate(
        (w) =>
            w is FilledButton ||
            w is OutlinedButton ||
            w is TextButton ||
            w is IconButton ||
            w is InkWell ||
            w is LocationTile,
      );
      expect(targets, findsWidgets);
      for (final element in targets.evaluate()) {
        final size = tester.getSize(
          find.byElementPredicate((e) => e == element),
        );
        expect(
          size.height,
          greaterThanOrEqualTo(TmbTheme.minTapTarget),
          reason: '${element.widget.runtimeType} ниже 48',
        );
      }
    });
  });
}
