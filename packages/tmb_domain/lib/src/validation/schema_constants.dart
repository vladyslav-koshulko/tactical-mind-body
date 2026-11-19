/// Паттерны и закрытые списки SCHEMAS §0–§2 для валидатора.
library;

import '../common/enums.dart';
import '../common/wire_enum.dart';
import '../content/task_archetype.dart';
import '../events/attempt_status.dart';

final packPattern = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$');
final domainPattern = RegExp(
  r'^[a-z][a-z0-9_]{0,31}(\.[a-z][a-z0-9_]{0,31}){1,4}$',
);
final taskIdPattern = RegExp(r'^[a-z0-9][a-z0-9_.-]{2,63}$');
final exerciseIdPattern = RegExp(r'^ex\.[a-z][a-z0-9_]{1,47}$');
final localePattern = RegExp(r'^[a-z]{2}(-[A-Z]{2})?$');
final tagPattern = RegExp(r'^[a-z][a-z0-9_]{1,31}$');
final licensePattern = RegExp(r'^[A-Za-z0-9.+-]+$');
final uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
final hashPattern = RegExp(r'^[0-9a-f]{64}$');

/// Разметка (решение 23): комментарий или тег с закрывающей `>`.
final markupPattern = RegExp(r'<!--|</?[A-Za-z][A-Za-z0-9-]*(\s[^<>]*)?/?>');

List<String> wires(List<WireEnum> values) => [for (final v in values) v.wire];

final archetypeWires = wires(TaskArchetype.values);
final packSourceWires = wires(PackSource.values);
final packStatusWires = wires(PackStatus.values);
final levelWires = wires(DifficultyLevel.values);
final locationWires = wires(Location.values);
final unitWires = wires(ExerciseUnit.values);
final templateWires = wires(SessionTemplateKind.values);
final attemptStatusWires = wires(AttemptStatus.values);

/// Известные теги v1 (открытые списки, решение 15).
const knownMuscleGroups = {
  'chest',
  'back',
  'shoulders',
  'biceps',
  'triceps',
  'core',
  'glutes',
  'quads',
  'hamstrings',
  'calves',
  'full_body',
};

const knownInventory = {
  'pullup_bar',
  'dumbbell',
  'kettlebell',
  'barbell',
  'bench',
  'resistance_band',
  'jump_rope',
  'box',
};

/// Верхняя граница времени событий: 2100-01-01 UTC, мс.
const maxEventTimeMs = 4102444800000;

/// Максимум `seed`: 2^53 − 1.
const maxSeed = 9007199254740991;
