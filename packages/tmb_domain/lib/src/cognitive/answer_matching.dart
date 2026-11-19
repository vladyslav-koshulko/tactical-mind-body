import '../common/text.dart';
import '../content/accept.dart';

final _spaces = RegExp(r'\s+');

/// Вся строка — число (SCHEMAS §1.4): пробел, NBSP и узкий NBSP — разделители
/// разрядов.
final _numeric = RegExp('^-?[0-9   ]*[0-9]([.,][0-9]+)?\$');
final _groupSpaces = RegExp('[   ]');

/// Нормализованный ответ: текст и, если вся строка — число, его значение.
final class NormalizedAnswer {
  const NormalizedAnswer(this.text, this.number);

  final String text;
  final double? number;
}

/// Нормализация ответа recall: NFC → trim → схлопнуть пробельные в один
/// пробел → нижний регистр → `ё`→`е`. Если вся строка — число, пробелы
/// удаляются, `,`→`.`, значение разбирается как число.
NormalizedAnswer normalizeAnswer(String input) {
  final text = normalizeText(input)
      .trim()
      .replaceAll(_spaces, ' ')
      .toLowerCase()
      .replaceAll('ё', 'е');
  double? number;
  if (_numeric.hasMatch(text)) {
    number = double.tryParse(
      text.replaceAll(_groupSpaces, '').replaceAll(',', '.'),
    );
  }
  return NormalizedAnswer(text, number);
}

/// Совпадает ли ввод пользователя с эталоном ([String] или [num]).
bool _equalsExpected(NormalizedAnswer input, Object expected) {
  if (expected is num) {
    final n = input.number;
    return n != null && n == expected.toDouble();
  }
  final exp = normalizeAnswer(expected as String);
  if (exp.number != null && input.number != null) {
    return exp.number == input.number;
  }
  return exp.text == input.text;
}

/// Проверка ответа `recall`/`delayed_recall` (SCHEMAS §1.4).
///
/// Верно, если ввод совпадает с [answer], с любым элементом [accept]-массива
/// либо (при числовом ответе) попадает в диапазон [accept] включительно.
/// Ввод, не являющийся числом, для диапазона — неверный. Ввод, который не
/// удаётся нормализовать (комбинируемые знаки), считается неверным: домен не
/// умеет его сравнивать, а не угадывает.
bool matchesRecall(String input, Object answer, Accept? accept) {
  final NormalizedAnswer given;
  try {
    given = normalizeAnswer(input);
  } on UnsupportedError {
    return false;
  }
  if (_equalsExpected(given, answer)) return true;
  switch (accept) {
    case null:
      return false;
    case AcceptList(:final values):
      return values.any((v) => _equalsExpected(given, v));
    case AcceptRange():
      final n = given.number;
      return n != null && accept.contains(n);
  }
}
