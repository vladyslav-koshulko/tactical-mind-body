// Сквозной тест на эмуляторе/устройстве: настоящая БД (Drift + sqlite на
// устройстве), настоящие паки из assets, настоящий роутер. Запускается через
// `scripts/emu.sh test` (или целиком — `scripts/ci-local.sh`), скриншоты каждого
// шага складываются в build/local-ci/screenshots/.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_mobile/features/session/session_screen.dart';
import 'package:tmb_mobile/features/session/session_summary_screen.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

final _l10n = AppLocalizationsRu();

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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot(name);
  }

  testWidgets('дашборд → сессия → эвакуация → итоги → дашборд', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TmbApp()));
    await binding.convertFlutterSurfaceToImage();

    // 1. Дашборд.
    await _waitFor(tester, _label(_l10n.startOperation));
    await shot(tester, '01_dashboard');

    // 2. Старт: должен собраться план и открыться физическая фаза.
    await tester.tap(_label(_l10n.startOperation));
    await _waitFor(tester, _label(_l10n.sessionSetDone));
    expect(find.byType(SessionScreen), findsOneWidget);
    expect(_label(_l10n.sessionErrorTitle), findsNothing);
    await shot(tester, '02_session_physical');

    // 3. Один подход.
    await tester.tap(_label(_l10n.sessionSetDone));
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, '03_after_set');

    // 4. Эвакуация с подтверждением.
    await tester.tap(_label(_l10n.sessionEvacuate));
    await _waitFor(tester, _label(_l10n.sessionEvacuateConfirm));
    await shot(tester, '04_evacuate_dialog');
    await tester.tap(_label(_l10n.sessionEvacuateConfirm));

    // 5. Итоги: сессия записана, статус «Прервана».
    await _waitFor(tester, find.byType(SessionSummaryScreen));
    await _waitFor(tester, _label(_l10n.sessionSummaryStatusAborted));
    await shot(tester, '05_summary');

    // 6. Назад на дашборд.
    await tester.tap(_label(_l10n.sessionSummaryToDashboard).first);
    await _waitFor(tester, _label(_l10n.startOperation));
    await shot(tester, '06_dashboard_after');
  });
}
