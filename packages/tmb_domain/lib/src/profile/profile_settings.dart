import '../common/json_reader.dart';
import 'category_filter.dart';
import 'targets.dart';

/// Фрагменты профиля, которые определяет SCHEMAS §4.
///
/// Профиль хранится в БД пользователя, не в паках. Правило «пул не бывает
/// пустым» (`PROF_EMPTY_POOL`) проверяется при записи и здесь не реализуется.
final class ProfileSettings {
  const ProfileSettings({
    this.schemaVersion = 1,
    this.disabledCategories = const [],
    this.defaultTargets = DefaultTargets.standard,
    this.exerciseTargets = const [],
    this.progression = const ProgressionSettings(),
  });

  factory ProfileSettings.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    return ProfileSettings(
      schemaVersion: o.integer('schemaVersion'),
      disabledCategories: o.req('disabledCategories', listOf(convString)),
      defaultTargets: DefaultTargets.read(o.object('defaultTargets')),
      exerciseTargets: o.req(
        'exerciseTargets',
        listOf((v, p) => ExerciseTarget.read(convObject(v, p))),
      ),
      progression: ProgressionSettings.read(o.object('progression')),
    );
  }

  final int schemaVersion;

  /// Множество ОТКЛЮЧЁННЫХ путей `domain` (D2); остальные категории включены.
  final List<String> disabledCategories;
  final DefaultTargets defaultTargets;
  final List<ExerciseTarget> exerciseTargets;
  final ProgressionSettings progression;

  bool isEnabled(String domain) =>
      isCategoryEnabled(domain, disabledCategories);

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'disabledCategories': disabledCategories,
    'defaultTargets': defaultTargets.toJson(),
    'exerciseTargets': exerciseTargets.map((e) => e.toJson()).toList(),
    'progression': progression.toJson(),
  };
}
