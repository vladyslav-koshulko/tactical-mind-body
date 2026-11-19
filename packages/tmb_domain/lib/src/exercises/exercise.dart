import '../common/enums.dart';
import '../common/json_reader.dart';

/// Упражнение (`exercises[]`, SCHEMAS §2.2).
///
/// `id` неизменяем: на него ссылаются `ExerciseSet` и профиль.
final class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.unit,
    required this.muscleGroups,
    required this.inventory,
    required this.locations,
    this.legacyId,
  });

  factory Exercise.fromJson(Map<String, Object?> json) =>
      Exercise.read(readRoot(json));

  factory Exercise.read(JsonObj o) => Exercise(
    id: o.string('id'),
    name: _readName(o.object('name')),
    unit: o.enumValue('unit', ExerciseUnit.values),
    muscleGroups: o.req('muscleGroups', listOf(convString)),
    inventory: o.req('inventory', listOf(convString)),
    locations: o.req('locations', listOf(enumOf(Location.values))),
    legacyId: o.integerN('legacyId'),
  );

  /// Идентификатор вида `ex.pushup`.
  final String id;

  /// Карта «локаль → название».
  final Map<String, String> name;
  final ExerciseUnit unit;

  /// Открытые теги (неизвестный, но правильный тег сохраняется).
  final List<String> muscleGroups;

  /// Открытые теги; пустой список — без инвентаря.
  final List<String> inventory;
  final List<Location> locations;

  /// Числовой id из прототипа или `null` у новых упражнений.
  final int? legacyId;

  /// Название по локали: запрошенная → [defaultLocale] (SCHEMAS §2.2).
  /// Возвращает `null`, если нет ни той, ни другой.
  String? nameFor(String locale, {required String defaultLocale}) =>
      name[locale] ?? name[defaultLocale];

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'unit': unit.wire,
    'muscleGroups': muscleGroups,
    'inventory': inventory,
    'locations': locations.map((e) => e.wire).toList(),
    'legacyId': legacyId,
  };
}

Map<String, String> _readName(JsonObj o) =>
    Map.unmodifiable({for (final key in o.map.keys) key: o.text(key)});
