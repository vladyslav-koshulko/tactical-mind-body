import '../content/cue.dart';
import 'mulberry32.dart';

/// Моменты показа подсказок `verbal` в секундах (SCHEMAS §9, решение 25).
///
/// Подсказке `i` соответствует `i`-й вызов `next()` генератора — не меньше и
/// не больше, даже если диапазон вырожден (`a == b`): так добавление подсказки
/// в конец не меняет моменты предыдущих. Момент — равномерно среди целых
/// секунд диапазона, включая границы.
List<int> cueMoments({
  required int seed,
  required String taskId,
  required List<Cue> cues,
}) {
  final rng = Mulberry32.forTask(seed: seed, taskId: taskId);
  return [for (final cue in cues) rng.nextIntInRange(cue.fromSec, cue.toSec)];
}
