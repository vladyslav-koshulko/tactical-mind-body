import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_ui/tmb_ui.dart';

/// Шрифты должны реально подключаться, а не молча уходить в системный фолбэк:
/// ни анализатор, ни остальные тесты этого не заметят.
///
/// `flutter test` сам не загружает шрифты приложения (рисует заглушкой Ahem),
/// поэтому манифест проверяется отдельно, а отрисовка — после явной загрузки.
double _width(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

const _asset = {
  TmbFont.display: 'assets/fonts/Oswald.ttf',
  TmbFont.mono: 'assets/fonts/JetBrainsMono.ttf',
};

// Украинские буквы — проверка кириллицы из docs/DESIGN.md.
const _sample = 'Розпочати операцію їжак єдність ґанок';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final entry in _asset.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  test('pubspec объявляет оба семейства из TmbFont', () async {
    final raw = await rootBundle.loadString('FontManifest.json');
    final manifest = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    final families = {for (final f in manifest) f['family']: f};
    for (final entry in _asset.entries) {
      expect(families, contains(entry.key), reason: 'нет ${entry.key}');
      final fonts = (families[entry.key]!['fonts']! as List)
          .cast<Map<String, Object?>>();
      expect(fonts.map((f) => f['asset']), contains(entry.value));
    }
  });

  test('Oswald рисуется настоящим шрифтом, а не фолбэком', () {
    final oswald = _width(
      _sample,
      const TextStyle(fontFamily: TmbFont.display, fontSize: 20),
    );
    final fallback = _width(
      _sample,
      const TextStyle(fontFamily: 'NoSuchFont', fontSize: 20),
    );
    expect(oswald, isNot(closeTo(fallback, 0.5)));
  });

  test('JetBrains Mono моноширинный и покрывает кириллицу', () {
    const style = TextStyle(fontFamily: TmbFont.mono, fontSize: 20);
    expect(
      _width('iiiiiiiiii', style),
      closeTo(_width('WWWWWWWWWW', style), 0.5),
    );
    // Кириллица не должна уходить в фолбэк: ширина строки из 10 букв равна
    // ширине 10 латинских знаков того же моно-шрифта.
    expect(
      _width('їєґіїєґіїє', style),
      closeTo(_width('iiiiiiiiii', style), 0.5),
    );
  });

  test('вес действует: FontWeight применяется к оси wght', () {
    double at(FontWeight weight) => _width(
      _sample,
      TextStyle(fontFamily: TmbFont.display, fontSize: 20, fontWeight: weight),
    );
    expect(at(FontWeight.w500), greaterThan(at(FontWeight.w400) + 0.5));
    expect(at(FontWeight.w700), greaterThan(at(FontWeight.w500) + 0.5));
  });
}
