// Драйвер для `flutter drive`: сохраняет скриншоты интеграционного теста
// в каталог $TMB_OUT/screenshots (по умолчанию build/local-ci/screenshots).
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final out =
      '${Platform.environment['TMB_OUT'] ?? 'build/local-ci'}/screenshots';
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('$out/$name.png')..createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}
