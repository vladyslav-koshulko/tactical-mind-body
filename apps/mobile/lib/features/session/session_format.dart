import 'package:tmb_domain/tmb_domain.dart';

/// `мм:сс` с округлением вверх: таймер показывает `00:01`, пока осталась
/// хоть доля секунды, и `00:00` только по сроку. Минуты не ограничены.
String formatMmSs(int ms) {
  final totalSec = ms <= 0 ? 0 : (ms + 999) ~/ 1000;
  final m = totalSec ~/ 60;
  final s = totalSec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Название упражнения на языке [languageCode]; нет такого — русское, иначе
/// первое из имеющихся (в базовом паке только `ru`, `uk` ждёт переводчика).
String exerciseName(Exercise exercise, String languageCode) =>
    exercise.name[languageCode] ??
    exercise.name['ru'] ??
    exercise.name.values.first;

/// Итог проверяемой попытки одной строкой для тестов и баннера: `reveal`
/// задачи или `null` (у `verbal` его нет по схеме, решение 22).
String? taskReveal(CognitiveTask task) => switch (task) {
  RecallTask t => t.reveal,
  ChoiceTask t => t.reveal,
  OrderingTask t => t.reveal,
  DelayedRecallTask t => t.reveal,
  SpatialTask t => t.reveal,
  StreamTask t => t.reveal,
  VerbalTask() => null,
};
