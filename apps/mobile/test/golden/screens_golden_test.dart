@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/features/session/session_services.dart';

import '../features/settings/settings_test_support.dart';

/// Скриншот-тесты экранов (golden). Нужны, чтобы глазами увидеть вёрстку без
/// устройства: PNG лежат в `test/golden/goldens/`.
///
/// Запуск:   `scripts/golden.sh`            — сверка с эталонами;
/// Обновить: `scripts/golden.sh --update`   — после осознанной правки вёрстки.
///
/// `flutter test` рисует текст заглушкой Ahem, пока шрифты не загружены явно,
/// поэтому Oswald и JetBrains Mono грузятся здесь из файлов приложения.
Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont('Oswald', 'assets/fonts/Oswald.ttf');
    await _loadFont('JetBrains Mono', 'assets/fonts/JetBrainsMono.ttf');
    // Иконки Material: без шрифта они рисуются пустыми квадратами.
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    final icons =
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
    if (flutterRoot != null && File(icons).existsSync()) {
      await _loadFont('MaterialIcons', icons);
    }
  });

  final screens = <String, String>{
    'dashboard': TmbRoutes.home,
    'session_start': TmbRoutes.session,
    'settings': TmbRoutes.settings,
    'categories': TmbRoutes.categories,
  };

  for (final entry in screens.entries) {
    testWidgets('golden: ${entry.key}', (tester) async {
      await pumpApp(
        tester,
        initialLocation: entry.value,
        // Сид сессии случаен: без фиксации на скриншоте каждый раз другие упражнения.
        overrides: [sessionSeedProvider.overrideWithValue(() => 20260101)],
      );
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
    });
  }

  testWidgets('golden: dashboard (uk)', (tester) async {
    await pumpApp(tester, locale: const Locale('uk'));
    await expectLater(
      find.byType(WidgetsApp),
      matchesGoldenFile('goldens/dashboard_uk.png'),
    );
  });

  testWidgets('golden: dashboard (320 px, текст ×1.5)', (tester) async {
    await pumpApp(tester, width: narrowLogicalWidth, textScale: bigTextScale);
    await expectLater(
      find.byType(WidgetsApp),
      matchesGoldenFile('goldens/dashboard_narrow_big_text.png'),
    );
  });
}
