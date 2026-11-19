import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

void main() {
  group('canonicalJson', () {
    test('ключи по возрастанию, без пробелов', () {
      expect(
        canonicalJson({
          'b': 1,
          'a': [true, false],
          'c': 'x',
        }),
        '{"a":[true,false],"b":1,"c":"x"}',
      );
    });

    test('вложенные объекты сортируются рекурсивно', () {
      expect(
        canonicalJson({
          'z': {'b': 1, 'a': 2},
          'a': 0,
        }),
        '{"a":0,"z":{"a":2,"b":1}}',
      );
    });

    test('числа: целое без .0, -0 → 0', () {
      expect(canonicalJson(5.0), '5');
      expect(canonicalJson(-0.0), '0');
      expect(canonicalJson(86400), '86400');
      expect(canonicalJson(-3), '-3');
      expect(canonicalJson(1e14), '100000000000000');
    });

    test('числа: дробное кратчайшее, без экспоненты', () {
      expect(canonicalJson(0.35), '0.35');
      expect(canonicalJson(0.000001), '0.000001');
      expect(canonicalJson(1e-7), '0.0000001');
      expect(canonicalJson(123456789012.5), '123456789012.5');
      expect(canonicalJson(-0.5), '-0.5');
      expect(canonicalJson(1.5e-7), '0.00000015');
    });

    test('нечисловые и неподдерживаемые значения', () {
      expect(() => canonicalJson(double.nan), throwsArgumentError);
      expect(() => canonicalJson(double.infinity), throwsArgumentError);
      expect(() => canonicalJson({'a': null}), throwsArgumentError);
      expect(() => canonicalJson(DateTime(2020)), throwsArgumentError);
    });

    test('экранирование строго по списку §3.5', () {
      expect(canonicalJson('a"b\\c'), r'"a\"b\\c"');
      expect(canonicalJson('\b\t\n\f'), r'"\b\t\n\f"');
      expect(canonicalJson('\x00\x01\x1f'), r'"\u0000\u0001\u001f"');
      // Буквально: /, U+007F, кириллица, эмодзи.
      expect(canonicalJson('a/b\x7f'), '"a/b\x7f"');
      expect(canonicalJson('Ёж и 😀'), '"Ёж и 😀"');
    });

    test(r'\r\n → \n', () {
      expect(canonicalJson('a\r\nb'), r'"a\nb"');
    });

    test('комбинируемые знаки — UnsupportedError с понятным текстом', () {
      expect(
        () => canonicalJson('é'),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('NFC'),
          ),
        ),
      );
    });

    test('кириллица (в т.ч. і ї є ґ) проходит NFC без изменений', () {
      expect(nfc('Йй Ёё і ї є ґ'), 'Йй Ёё і ї є ґ');
    });
  });
}
