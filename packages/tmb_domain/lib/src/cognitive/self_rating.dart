/// Самооценка `verbal`: `floor(3 × yes / n + 0.5)` (SCHEMAS §1.4, решение 14).
///
/// [n] — число вопросов самопроверки, [yes] — число ответов «да» (`0 … n`).
/// Считается в целых: `3·yes/n + 1/2 = (6·yes + n) / (2n)`, поэтому
/// `floor` — это целочисленное деление и никакой погрешности double.
int selfRating({required int yes, required int n}) {
  if (n < 1) throw ArgumentError.value(n, 'n', 'должно быть ≥ 1');
  if (yes < 0 || yes > n) {
    throw RangeError.range(yes, 0, n, 'yes');
  }
  return (6 * yes + n) ~/ (2 * n);
}
