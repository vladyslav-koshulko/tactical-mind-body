/// Пределы значений, которые можно выставить на экранах настроек.
///
/// Цели упражнений — из схемы: SCHEMAS §4, `Range`: `1 ≤ min ≤ max ≤ 3600`
/// (`PROF_TARGET_RANGE`; в `tmb_domain` эти числа не экспортированы, они
/// зашиты в профильном валидаторе). Остальное — решения экрана настроек:
/// границы, при которых пользователь не соберёт заведомо бессмысленную
/// операцию, но домен сам их не требует (он принимает любое значение ≥ 1).
abstract final class SettingsLimits {
  /// Нижняя граница цели упражнения (`PROF_TARGET_RANGE`).
  static const targetMin = 1;

  /// Верхняя граница цели упражнения (`PROF_TARGET_RANGE`).
  static const targetMax = 3600;

  /// Шаги ± для целей: повторения — по одному, секунды — по пять.
  static const repsStep = 1;
  static const secondsStep = 5;

  /// На сколько расширяется фиксированная цель при переходе в «Диапазон»
  /// (max = min + spread, не выше [targetMax]).
  static const repsRangeSpread = 5;
  static const secondsRangeSpread = 10;

  static const roundsMin = 1;
  static const roundsMax = 20;

  static const cognitiveSecMin = 30;
  static const cognitiveSecMax = 600;
  static const cognitiveSecStep = 15;

  static const restSecMin = 0;
  static const restSecMax = 300;
  static const restSecStep = 15;
}
