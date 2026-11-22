import 'package:tmb_domain/tmb_domain.dart';

/// Порядок показа `n` вариантов `choice`/`ordering`: Fisher–Yates по
/// `Mulberry32.forTask(seed, taskId)` (SCHEMAS §9, решение 27). Результат —
/// перестановка индексов: на позиции `i` показывается элемент `result[i]`
/// исходного списка, поэтому `response` по-прежнему пишется по исходному
/// порядку (§3.4).
///
/// [seed] — `PlannedTask.seed`: одинаковая задача и сид дают одинаковый
/// порядок на любом устройстве (инвариант 4). При [mustDiffer] перестановка
/// обязана отличаться от исходной (`ordering`, §1.4): тождественная
/// сдвигается на один шаг.
///
/// Чистый Dart: когда понадобится серверная перепроверка показа, функция
/// переедет в `tmb_domain`.
List<int> shuffledOrder(
  int n, {
  required int seed,
  required String taskId,
  bool mustDiffer = false,
}) {
  final order = List<int>.generate(n, (i) => i);
  if (n < 2) return order;
  final rng = Mulberry32.forTask(seed: seed, taskId: taskId);
  for (var i = n - 1; i > 0; i--) {
    final j = rng.nextIntInRange(0, i);
    final tmp = order[i];
    order[i] = order[j];
    order[j] = tmp;
  }
  if (mustDiffer && _isIdentity(order)) {
    order.add(order.removeAt(0));
  }
  return order;
}

bool _isIdentity(List<int> order) {
  for (var i = 0; i < order.length; i++) {
    if (order[i] != i) return false;
  }
  return true;
}

/// Ответ `recall`/`delayed_recall` числовой: для него экран открывает
/// цифровую клавиатуру, иначе — текстовое поле (системная клавиатура).
bool isNumericAnswer(Object expected) =>
    expected is num || normalizeAnswer('$expected').number != null;
