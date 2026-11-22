import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/settings/about_screen.dart';
import 'package:tmb_mobile/features/settings/categories_screen.dart';
import 'package:tmb_mobile/features/settings/export_screen.dart';
import 'package:tmb_mobile/features/settings/settings_screen.dart';
import 'package:tmb_mobile/features/settings/targets_screen.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';
import 'package:tmb_mobile/l10n/app_localizations_uk.dart';

import 'settings_test_support.dart';

final _l10n = AppLocalizationsRu();

Future<SessionPreferences> _prefs(WidgetTester tester, ProviderContainer c) =>
    db(
      tester,
      () => c.read(profileRepositoryProvider).loadSessionPreferences(),
    );

Future<ProfileSettings> _profile(WidgetTester tester, ProviderContainer c) =>
    db(tester, () => c.read(profileRepositoryProvider).loadProfile());

Finder _tile(String label) => find.text(label.toUpperCase());

void main() {
  group('шаблон и параметры операции', () {
    testWidgets('по умолчанию показано то, что в БД (значения прототипа)', (
      tester,
    ) async {
      await pumpScreen(tester, const SettingsScreen());
      expect(find.text('5'), findsOneWidget); // кругов
      expect(find.text(_l10n.settingsSecondsValue(180)), findsOneWidget);
      // Режим «Dual-Task» выбран значком и рамкой, не только цветом.
      expect(find.byIcon(Icons.radio_button_checked), findsWidgets);
    });

    testWidgets('смена шаблона сохраняется сразу', (tester) async {
      final c = await pumpScreen(tester, const SettingsScreen());

      await tester.tap(_tile(_l10n.settingsTemplatePhysicalOnly));
      await settle(tester);
      expect(
        (await _prefs(tester, c)).template,
        SessionTemplateKind.physicalOnly,
      );

      await tester.tap(_tile(_l10n.settingsTemplateCognitiveOnly));
      await settle(tester);
      expect(
        (await _prefs(tester, c)).template,
        SessionTemplateKind.cognitiveOnly,
      );
      // Для «только когниции» — «окна», а не «круги».
      expect(find.text(_l10n.settingsWindows.toUpperCase()), findsOneWidget);
    });

    testWidgets('число кругов: ± сохраняется, границы держатся', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const SettingsScreen());

      await tester.tap(
        find.byTooltip(_l10n.settingsStepperIncrease(_l10n.settingsRounds)),
      );
      await settle(tester);
      expect((await _prefs(tester, c)).rounds, 6);

      final minus = find.byTooltip(
        _l10n.settingsStepperDecrease(_l10n.settingsRounds),
      );
      await tester.tap(minus);
      await settle(tester);
      await tester.tap(minus);
      await settle(tester);
      expect((await _prefs(tester, c)).rounds, 4);

      // Нижняя граница: кнопка «−» гаснет на минимуме.
      for (var i = 0; i < 5; i++) {
        await tester.tap(minus, warnIfMissed: false);
        await settle(tester);
      }
      expect((await _prefs(tester, c)).rounds, 1);
    });

    testWidgets(
      'ввод числа: вне предела — подсказка диапазона, в пределе — сохранение',
      (tester) async {
        final c = await pumpScreen(tester, const SettingsScreen());

        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '99');
        await tester.tap(find.text(_l10n.settingsConfirm.toUpperCase()));
        await tester.pumpAndSettle();
        expect(
          find.text(_l10n.settingsStepperRangeError(1, 20)),
          findsOneWidget,
        );
        expect((await _prefs(tester, c)).rounds, 5);

        await tester.enterText(find.byType(TextField), '12');
        await tester.tap(find.text(_l10n.settingsConfirm.toUpperCase()));
        await settle(tester);
        expect((await _prefs(tester, c)).rounds, 12);
      },
    );

    testWidgets('когнитивное окно сохраняется; отдых виден только в «физике»', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const SettingsScreen());
      expect(find.text(_l10n.settingsRestSec.toUpperCase()), findsNothing);

      await tester.tap(
        find.byTooltip(
          _l10n.settingsStepperIncrease(_l10n.settingsCognitiveSec),
        ),
      );
      await settle(tester);
      expect((await _prefs(tester, c)).cognitiveSec, 195);

      await tester.tap(_tile(_l10n.settingsTemplatePhysicalOnly));
      await settle(tester);
      expect(find.text(_l10n.settingsCognitiveSec.toUpperCase()), findsNothing);
      expect(find.text(_l10n.settingsRestNone), findsOneWidget);

      await tester.tap(
        find.byTooltip(_l10n.settingsStepperIncrease(_l10n.settingsRestSec)),
      );
      await settle(tester);
      expect((await _prefs(tester, c)).restSec, 15);
    });
  });

  group('режим повторений', () {
    testWidgets('фикс → диапазон → фикс через defaultTargets', (tester) async {
      final c = await pumpScreen(tester, const SettingsScreen());
      await reveal(tester, _tile(_l10n.settingsRepsModeRange));

      expect((await _profile(tester, c)).defaultTargets.reps.isFixed, isTrue);

      await tester.tap(_tile(_l10n.settingsRepsModeRange));
      await settle(tester);
      var targets = (await _profile(tester, c)).defaultTargets;
      expect(targets.reps.min, 15);
      expect(targets.reps.max, greaterThan(15));
      expect(targets.seconds.max, greaterThan(targets.seconds.min));

      await tester.ensureVisible(_tile(_l10n.settingsRepsModeFixed));
      await tester.pumpAndSettle();
      await tester.tap(_tile(_l10n.settingsRepsModeFixed));
      await settle(tester);
      targets = (await _profile(tester, c)).defaultTargets;
      expect(targets.reps.isFixed, isTrue);
      expect(targets.seconds.isFixed, isTrue);
      expect(targets.reps.min, 15);
    });

    testWidgets('в диапазоне границы не пересекаются', (tester) async {
      final c = await pumpScreen(tester, const SettingsScreen());
      await reveal(tester, _tile(_l10n.settingsRepsModeRange));
      await tester.tap(_tile(_l10n.settingsRepsModeRange));
      await settle(tester);

      final fromLabel =
          '${_l10n.settingsTargetReps} · ${_l10n.settingsTargetFrom}';
      final toLabel = '${_l10n.settingsTargetReps} · ${_l10n.settingsTargetTo}';
      final incFrom = find.byTooltip(_l10n.settingsStepperIncrease(fromLabel));
      await reveal(tester, incFrom);
      // «От» нельзя поднять до «До» (15–20): режим «диапазон» не схлопывается.
      for (var i = 0; i < 8; i++) {
        await tester.tap(incFrom, warnIfMissed: false);
        await settle(tester);
      }
      final reps = (await _profile(tester, c)).defaultTargets.reps;
      expect(reps.min, 19);
      expect(reps.max, 20);
      expect(
        find.byTooltip(_l10n.settingsStepperIncrease(toLabel)),
        findsOneWidget,
      );
    });
  });

  group('прогрессия', () {
    testWidgets(
      'переключатель пишет только флаг, подпись честно говорит про v0.2',
      (tester) async {
        final c = await pumpScreen(tester, const SettingsScreen());
        await reveal(tester, find.text(_l10n.settingsProgressionHint));
        expect(_l10n.settingsProgressionHint, contains('0.2'));
        expect((await _profile(tester, c)).progression.enabled, isTrue);

        await tester.tap(
          find.text(_l10n.settingsProgressionToggle.toUpperCase()),
        );
        await settle(tester);
        expect((await _profile(tester, c)).progression.enabled, isFalse);
        // Состояние продублировано текстом.
        expect(find.text(_l10n.settingsOff.toUpperCase()), findsOneWidget);

        await tester.tap(
          find.text(_l10n.settingsProgressionToggle.toUpperCase()),
        );
        await settle(tester);
        expect((await _profile(tester, c)).progression.enabled, isTrue);
      },
    );
  });

  group('ссылки', () {
    testWidgets('«Категории» открывает маршрут /settings/categories', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: TmbRoutes.settings);
      await reveal(
        tester,
        find.text(_l10n.settingsLinkCategories.toUpperCase()),
      );
      // Сводка: всё включено.
      expect(find.textContaining('Включено'), findsOneWidget);
      await tester.tap(find.text(_l10n.settingsLinkCategories.toUpperCase()));
      await settle(tester);
      expect(find.byType(CategoriesScreen), findsOneWidget);
    });

    testWidgets('цели, экспорт и «О приложении» открываются и возвращаются', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: TmbRoutes.settings);
      final cases = <String, Type>{
        _l10n.settingsLinkTargets: TargetsScreen,
        _l10n.settingsLinkExport: ExportScreen,
        _l10n.settingsLinkAbout: AboutScreen,
      };
      for (final entry in cases.entries) {
        final link = find.text(entry.key.toUpperCase());
        await reveal(tester, link);
        await tester.tap(link);
        await settle(tester);
        expect(find.byType(entry.value), findsOneWidget, reason: entry.key);

        await tester.tap(find.byTooltip(_l10n.settingsBack));
        await settle(tester);
        expect(find.byType(SettingsScreen), findsOneWidget);
      }
    });
  });

  group('вёрстка', () {
    testWidgets('uk: заголовок на украинском', (tester) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        locale: const Locale('uk'),
      );
      expect(
        find.text(AppLocalizationsUk().settingsTitle.toUpperCase()),
        findsOneWidget,
      );
    });

    for (final template in SessionTemplateKind.values.where(
      (k) => k != SessionTemplateKind.custom,
    )) {
      testWidgets('320 px, textScale 1.5: без overflow (${template.wire})', (
        tester,
      ) async {
        final c = await pumpScreen(
          tester,
          const SettingsScreen(),
          width: narrowLogicalWidth,
          textScale: bigTextScale,
        );
        await db(
          tester,
          () => c
              .read(profileRepositoryProvider)
              .saveSessionPreferences(
                SessionPreferences.standard.copyWith(template: template),
              ),
        );
        await settle(tester);
        // Режим «диапазон» занимает больше всего места.
        await reveal(tester, _tile(_l10n.settingsRepsModeRange));
        await tester.tap(_tile(_l10n.settingsRepsModeRange));
        await settle(tester);
        expect(tester.takeException(), isNull);
        for (var i = 0; i < 20; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}
