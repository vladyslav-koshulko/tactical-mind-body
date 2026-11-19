import '../common/json_reader.dart';

/// Подсказка `verbal` (`cues[]`): текст и диапазон секунд `[from, to]`,
/// внутри которого момент показа выбирается по сиду (SCHEMAS §9, решение 25).
final class Cue {
  const Cue({required this.fromSec, required this.toSec, required this.text});

  factory Cue.read(JsonObj o) {
    final range = o.req('atSec', listOf(convInt));
    if (range.length != 2) {
      throw FormatException('${o.pathOf('atSec')}: ожидалось [a, b]');
    }
    return Cue(fromSec: range[0], toSec: range[1], text: o.text('text'));
  }

  factory Cue.fromJson(Map<String, Object?> json) => Cue.read(readRoot(json));

  /// Начало диапазона, включительно.
  final int fromSec;

  /// Конец диапазона, включительно.
  final int toSec;
  final String text;

  Map<String, Object> toJson() => {
    'atSec': [fromSec, toSec],
    'text': text,
  };
}
