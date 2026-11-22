// LicenseRegistry живёт в foundation, а material_ui его не реэкспортирует.
import 'package:flutter/foundation.dart'
    show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:material_ui/material_ui.dart';

/// Тексты лицензий шрифтов (SIL OFL 1.1): пакет → ассет. Лежат рядом со
/// шрифтами и объявлены в `pubspec.yaml`.
const fontLicenseAssets = <String, String>{
  'Oswald': 'assets/fonts/OFL-Oswald.txt',
  'JetBrains Mono': 'assets/fonts/OFL-JetBrainsMono.txt',
};

bool _registered = false;

/// Регистрирует лицензии шрифтов в `LicenseRegistry`, чтобы стандартный
/// `showLicensePage` показал их рядом с лицензиями Flutter и пакетов.
/// Идемпотентна. Тексты читаются лениво — только когда открыта страница.
void registerFontLicenses(AssetBundle bundle) {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    for (final entry in fontLicenseAssets.entries) {
      yield LicenseEntryWithLineBreaks([
        entry.key,
      ], await bundle.loadString(entry.value));
    }
  });
}
