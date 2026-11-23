// Сквозные тесты на эмуляторе/устройстве: настоящая БД (Drift + sqlite на
// устройстве), настоящие паки из assets, настоящий роутер. Запускаются через
// `scripts/emu.sh test` (или целиком — `scripts/ci-local.sh`), скриншоты каждого
// шага складываются в build/local-ci/screenshots/.
//
// Тесты делят одну БД на устройстве, но не зависят друг от друга.
//
// Каждый сценарий сам стирает данные приложения и (при необходимости) сам
// выставляет нужные настройки — порядок и «грязное» состояние устройства не
// важны (`_resetAppState`). Тест можно гонять сколько угодно раз подряд.
//
//  1. дашборд → сессия → эвакуация → итоги → дашборд (быстрый дым-тест);
//  2. полная короткая сессия офлайн: настройки (2 круга, окно 30 с) → физика →
//     когнитивное окно (+ уход приложения в фон) → удержание до срока →
//     физика → оценка → итоги «Завершена» → дашборд;
//  3. украинская локаль: дашборд, настройки, физика, когниция, итоги.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/data/session_summary_store.dart';
import 'package:tmb_mobile/features/session/cognitive_view.dart';
import 'package:tmb_mobile/features/session/session_screen.dart';
import 'package:tmb_mobile/features/session/session_summary_screen.dart';
import 'package:tmb_mobile/features/session/task_views.dart';
import 'package:tmb_mobile/l10n/app_localizations.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';
import 'package:tmb_mobile/l10n/app_localizations_uk.dart';

/// `scripts/emu.sh test` включает настоящий уход в фон: следящий процесс на
/// хосте ловит маркер в logcat, жмёт HOME и возвращает приложение через adb.
/// Без флага (голый `flutter drive`) жизненный цикл имитируется в самом тесте.
const _realLifecycle = bool.fromEnvironment('TMB_REAL_LIFECYCLE');

/// Маркер для следящего процесса `scripts/emu.sh` (см. `lifecycle_watch`).
const _backgroundMarker = 'TMB_E2E_BACKGROUND';

final _ru = AppLocalizationsRu();
final _uk = AppLocalizationsUk();

/// Текст виджета без учёта регистра (заголовки и кнопки рисуются капсом).
Finder _label(String text) => find.byWidgetPredicate(
  (w) => w is Text && (w.data ?? '').toLowerCase() == text.toLowerCase(),
);

/// Прокручивает кадры, пока [finder] не найдётся: `pumpAndSettle` на экране
/// сессии не дождётся тишины — таймер и радар анимируются постоянно.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Не дождались: $finder (${timeout.inSeconds} с)');
}

/// Все видимые строки на экране: для сообщения об ошибке (снимок при падении
/// драйвер не пишет, а диагностика нужна).
String _visibleTexts() =>
    [for (final e in find.byType(Text).evaluate()) ?(e.widget as Text).data]
        .join(' | ');

/// Нажимает [finder] и даёт кадрам отработать (запись в БД, смена экрана).
/// Нет виджета — падение с понятным сообщением и списком видимых строк
/// (а не «Bad state: No element» из `ensureVisible`).
Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    fail('Нечего нажимать: $finder. На экране: ${_visibleTexts()}');
  }
  // Кнопка может стоять ниже экрана (ответ, пропуск и т. п. внутри прокрутки):
  // сначала докручиваем. «Эвакуация» закреплена и видна всегда.
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder.first);
  await tester.pump(const Duration(milliseconds: 400));
}

/// Поднимает приложение и приводит данные к чистому первому запуску: стирает
/// все таблицы БД и последнюю сводку, затем (если нужно) выставляет
/// [prefs]. Так сценарий не зависит ни от прошлых прогонов, ни от порядка тестов.
/// Возвращает после того, как дашборд показал кнопку старта на чистых данных.
Future<void> _startApp(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  Locale locale,
  AppLocalizations l10n, {
  SessionPreferences? prefs,
}) async {
  await tester.pumpWidget(ProviderScope(child: TmbApp(locale: locale)));
  await binding.convertFlutterSurfaceToImage();
  await _waitFor(tester, _label(l10n.startOperation));
  final container = ProviderScope.containerOf(
    tester.element(find.byType(TmbApp)),
  );
  // Работа с БД — настоящий async: runAsync, иначе фейковые часы теста её не дождутся.
  await tester.runAsync(() async {
    final db = container.read(databaseProvider);
    await db.transaction(() async {
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
    });
    await container.read(sessionSummaryStoreProvider).clear();
    if (prefs != null) {
      await container
          .read(profileRepositoryProvider)
          .saveSessionPreferences(prefs);
    }
  });
  await tester.pump(const Duration(milliseconds: 500));
  await _waitFor(tester, _label(l10n.startOperation));
}

/// Жмёт «Подход выполнен», пока кнопка есть: круг кончается, когда движок
/// уходит в когнитивное окно или на экран оценки.
Future<void> _doSets(WidgetTester tester, AppLocalizations l10n) async {
  for (var i = 0; i < 30; i++) {
    final button = _label(l10n.sessionSetDone);
    if (button.evaluate().isEmpty) return;
    await _tap(tester, button);
  }
  fail('Круг не кончился за 30 подходов');
}

/// Отвечает на текущую когнитивную задачу любым допустимым способом, пока не
/// начнётся удержание окна ([holdTitle]) или не уйдёт сам экран окна. Верность
/// ответа тут не важна: проверяется, что задача принимает ответ и сессия идёт
/// дальше. Поддержаны архетипы встроенных паков: recall (число и текст),
/// delayed_recall (запоминание → ответ), verbal (речь → самопроверка).
Future<void> _answerTasks(
  WidgetTester tester,
  AppLocalizations l10n, {
  required Finder until,
}) async {
  final end = DateTime.now().add(const Duration(seconds: 60));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (until.evaluate().isNotEmpty) return;
    final study = _label(l10n.sessionStudyDone);
    final finish = _label(l10n.sessionVerbalFinish);
    final yes = _label(l10n.sessionYes);
    final submit = _label(l10n.sessionAnswerSubmit);
    if (study.evaluate().isNotEmpty) {
      await _tap(tester, study);
    } else if (finish.evaluate().isNotEmpty) {
      await _tap(tester, finish);
    } else if (yes.evaluate().isNotEmpty) {
      // Самопроверка: «да» на каждый пункт, затем «Ответить».
      for (var i = 0; i < yes.evaluate().length; i++) {
        await tester.tap(yes.at(i));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await _tap(tester, submit);
    } else if (find.byType(TextField).evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).first, 'тест');
      await tester.pump(const Duration(milliseconds: 100));
      await _tap(tester, submit);
    } else if (find.text('7').evaluate().isNotEmpty &&
        submit.evaluate().isNotEmpty) {
      await _tap(tester, find.text('7')); // цифровая клавиатура
      await _tap(tester, submit);
    }
  }
  fail('Задачи окна не закрылись за 60 с. На экране: ${_visibleTexts()}');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name) async {
    // Несколько кадров подряд: снимок поверхности иногда отстаёт на кадр и
    // ловит переходный экран («Подготовка…», спиннер итогов).
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await binding.takeScreenshot(name);
  }

  testWidgets('дашборд → сессия → эвакуация → итоги → дашборд', (tester) async {
    await _startApp(tester, binding, const Locale('ru'), _ru);

    // 1. Дашборд на чистых данных: последней операции ещё нет.
    expect(_label(_ru.dashboardLastOperationInterrupted), findsNothing);
    expect(_label(_ru.dashboardLastOperationDone), findsNothing);
    await shot(tester, '01_dashboard');

    // 2. Старт: должен собраться план и открыться физическая фаза.
    await tester.tap(_label(_ru.startOperation));
    await _waitFor(tester, _label(_ru.sessionSetDone));
    expect(find.byType(SessionScreen), findsOneWidget);
    expect(_label(_ru.sessionErrorTitle), findsNothing);
    await shot(tester, '02_session_physical');

    // 3. Один подход.
    await tester.tap(_label(_ru.sessionSetDone));
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, '03_after_set');

    // 4. Эвакуация с подтверждением.
    await tester.tap(_label(_ru.sessionEvacuate));
    await _waitFor(tester, _label(_ru.sessionEvacuateConfirm));
    await shot(tester, '04_evacuate_dialog');
    await tester.tap(_label(_ru.sessionEvacuateConfirm));

    // 5. Итоги: сессия записана, статус «Прервана».
    await _waitFor(tester, find.byType(SessionSummaryScreen));
    await _waitFor(tester, _label(_ru.sessionSummaryStatusAborted));
    await shot(tester, '05_summary');

    // 6. Назад на дашборд.
    await tester.tap(_label(_ru.sessionSummaryToDashboard).first);
    await _waitFor(tester, _label(_ru.startOperation));
    // Дашборд помнит прерванную операцию.
    await _waitFor(tester, _label(_ru.dashboardLastOperationInterrupted));
    await shot(tester, '06_dashboard_after');
  });

  testWidgets('полная короткая сессия офлайн: настройки → физика → '
      'когниция (+ фон) → физика → «Завершена»', (tester) async {
    final l10n = _ru;
    await _startApp(tester, binding, const Locale('ru'), l10n);

    // 1. Чистый дашборд: на нём ещё нет ни «Прервана», ни «Завершена».
    expect(_label(l10n.dashboardLastOperationInterrupted), findsNothing);
    expect(_label(l10n.dashboardLastOperationDone), findsNothing);
    await shot(tester, '10_dashboard_before');

    // 2. Настройки: 2 круга (стоят 5) и окно 30 с (стоит 180) — иначе тест
    // ждал бы настоящие 3 минуты паузы.
    await tester.tap(find.byTooltip(l10n.dashboardSettings));
    await _waitFor(tester, _label(l10n.settingsSectionParams));
    await shot(tester, '11_settings_top');
    final lessRounds = find.byTooltip(
      l10n.settingsStepperDecrease(l10n.settingsRounds),
    );
    for (var i = 0; i < 3; i++) {
      await _tap(tester, lessRounds);
    }
    // Окно — через диалог ввода значения (вторая дорожка того же экрана).
    await _tap(tester, find.text(l10n.settingsSecondsValue(180)));
    await _waitFor(tester, find.byType(TextField));
    await shot(tester, '12_settings_value_dialog');
    await tester.enterText(find.byType(TextField), '30');
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, _label(l10n.settingsConfirm));
    await _waitFor(tester, find.text(l10n.settingsSecondsValue(30)));
    expect(find.text('2'), findsWidgets);
    await shot(tester, '13_settings_saved');
    // Остальные панели: кириллица и обрезания внизу списка.
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, '14_settings_bottom');
    await tester.tap(find.byTooltip(l10n.settingsBack));
    await _waitFor(tester, _label(l10n.startOperation));

    // 3. Старт: первый круг из двух.
    await tester.tap(_label(l10n.startOperation));
    await _waitFor(tester, _label(l10n.sessionSetDone));
    expect(_label(l10n.sessionRoundTitle(1, 2)), findsOneWidget);
    await shot(tester, '15_session_round1');
    await _doSets(tester, l10n);

    // 4. Когнитивное окно (экран 03), длина — из настроек.
    await _waitFor(tester, find.byType(CognitiveView));
    await shot(tester, '16_cognitive');

    // 5. Уход в фон посреди окна и возврат: заглушка паузы, задача скрыта.
    final promptsBefore = find.byType(TaskTextCard).evaluate().length;
    if (_realLifecycle) {
      debugPrint(_backgroundMarker);
    } else {
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump(const Duration(milliseconds: 500));
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }
    await _waitFor(
      tester,
      _label(l10n.sessionResume),
      timeout: const Duration(seconds: 45),
    );
    await shot(tester, '17_paused_stub');
    expect(_label(l10n.sessionPausedTitle), findsOneWidget);
    if (promptsBefore > 0) {
      // Условие задачи под заглушкой не видно (Offstage).
      expect(find.byType(TaskTextCard), findsNothing);
    }
    await _tap(tester, _label(l10n.sessionResume));
    expect(_label(l10n.sessionResume), findsNothing);
    expect(find.byType(CognitiveView), findsOneWidget);
    if (promptsBefore > 0) expect(find.byType(TaskTextCard), findsWidgets);
    await shot(tester, '18_cognitive_resumed');

    // 6. Ответ на задачу → удержание окна до срока (D15).
    await _answerTasks(
      tester,
      l10n,
      until: find.byWidgetPredicate(
        (w) =>
            w is Text &&
            [
              l10n.sessionHoldTitle,
              l10n.sessionRoundTitle(2, 2),
            ].any((t) => (w.data ?? '').toLowerCase() == t.toLowerCase()),
      ),
    );
    if (_label(l10n.sessionHoldTitle).evaluate().isNotEmpty) {
      await shot(tester, '19_hold');
      expect(_label(l10n.sessionHoldNext), findsOneWidget);
    } else {
      // Остаток окна < kMinHoldMs: удержания не было, круг 2 пошёл сразу.
      debugPrint('TMB_E2E: удержание окна пропущено (остаток < 1 с)');
    }

    // 7. Срок вышел → круг 2; оцениваем круг 1 и делаем подходы.
    await _waitFor(
      tester,
      _label(l10n.sessionRoundTitle(2, 2)),
      timeout: const Duration(seconds: 60),
    );
    await _waitFor(tester, _label(l10n.sessionRatingTitle));
    await _tap(tester, _label(l10n.sessionEffortNormal));
    await shot(tester, '20_round2_rated');
    await _doSets(tester, l10n);

    // 8. Оценка последнего круга → «К итогам».
    await _waitFor(tester, _label(l10n.sessionToSummary));
    await _tap(tester, _label(l10n.sessionEffortHard));
    await shot(tester, '21_final_rating');
    await _tap(tester, _label(l10n.sessionToSummary));

    // 9. Итоги: «Завершена», два круга.
    await _waitFor(tester, find.byType(SessionSummaryScreen));
    await _waitFor(tester, _label(l10n.sessionSummaryStatusCompleted));
    expect(_label(l10n.sessionSummaryStatusAborted), findsNothing);
    await shot(tester, '22_summary_completed');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, '23_summary_bottom');

    // 10. Дашборд показывает последнюю операцию уже завершённой.
    await _tap(tester, _label(l10n.sessionSummaryToDashboard));
    await _waitFor(tester, _label(l10n.startOperation));
    await _waitFor(tester, _label(l10n.dashboardLastOperationDone));
    expect(_label(l10n.dashboardLastOperationInterrupted), findsNothing);
    expect(find.textContaining('Кругов: 2'), findsOneWidget);
    expect(find.textContaining('Задач: '), findsOneWidget);
    await shot(tester, '24_dashboard_after_completed');
  });

  testWidgets(
    'украинская локаль: дашборд, настройки, физика, когниция, итоги',
    (tester) async {
      final l10n = _uk;
      // Два круга и короткое окно заданы тут, а не унаследованы от прошлого теста.
      await _startApp(
        tester,
        binding,
        const Locale('uk'),
        l10n,
        prefs: const SessionPreferences(rounds: 2, cognitiveSec: 30),
      );
      await shot(tester, '30_uk_dashboard');

      await tester.tap(find.byTooltip(l10n.dashboardSettings));
      await _waitFor(tester, _label(l10n.settingsSectionParams));
      await shot(tester, '31_uk_settings_top');
      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pump(const Duration(milliseconds: 500));
      await shot(tester, '32_uk_settings_bottom');
      await tester.tap(find.byTooltip(l10n.settingsBack));
      await _waitFor(tester, _label(l10n.startOperation));

      await tester.tap(_label(l10n.startOperation));
      await _waitFor(tester, _label(l10n.sessionSetDone));
      expect(_label(l10n.sessionRoundTitle(1, 2)), findsOneWidget);
      await shot(tester, '33_uk_session_physical');
      await _doSets(tester, l10n);

      await _waitFor(tester, find.byType(CognitiveView));
      await shot(tester, '34_uk_cognitive');

      await _tap(tester, _label(l10n.sessionEvacuate));
      await _waitFor(tester, _label(l10n.sessionEvacuateConfirm));
      await shot(tester, '35_uk_evacuate_dialog');
      await tester.tap(_label(l10n.sessionEvacuateConfirm));

      await _waitFor(tester, _label(l10n.sessionSummaryStatusAborted));
      await shot(tester, '36_uk_summary');
      await _tap(tester, _label(l10n.sessionSummaryToDashboard));
      await _waitFor(tester, _label(l10n.startOperation));
      await shot(tester, '37_uk_dashboard_after');
    },
  );
}
