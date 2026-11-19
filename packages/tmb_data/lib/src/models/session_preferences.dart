import 'package:tmb_domain/tmb_domain.dart';

/// Последние выбранные параметры сессии (экран «Операция»).
///
/// Режим повторений (`fixed`/`range` прототипа) здесь не хранится: он —
/// `ProfileSettings.defaultTargets` (`min == max` — фиксированная цель).
/// Кастомные блоки (`SessionTemplateKind.custom`) в v0.1 не сохраняются.
final class SessionPreferences {
  const SessionPreferences({
    this.template = SessionTemplateKind.dualTask,
    this.rounds = 5,
    this.cognitiveSec = 180,
    this.restSec = 0,
    this.location = Location.home,
    this.difficulty = DifficultyLevel.recruit,
  });

  /// Значения прототипа: 5 кругов, пауза 180 с, дом, «рекрут».
  static const standard = SessionPreferences();

  final SessionTemplateKind template;

  /// Число физических кругов (≥ 1).
  final int rounds;

  /// Длительность когнитивного окна, секунды.
  final int cognitiveSec;

  /// Пассивный отдых между кругами в `physical_only`, секунды (0 — без него).
  final int restSec;
  final Location location;
  final DifficultyLevel difficulty;

  SessionPreferences copyWith({
    SessionTemplateKind? template,
    int? rounds,
    int? cognitiveSec,
    int? restSec,
    Location? location,
    DifficultyLevel? difficulty,
  }) => SessionPreferences(
    template: template ?? this.template,
    rounds: rounds ?? this.rounds,
    cognitiveSec: cognitiveSec ?? this.cognitiveSec,
    restSec: restSec ?? this.restSec,
    location: location ?? this.location,
    difficulty: difficulty ?? this.difficulty,
  );

  @override
  bool operator ==(Object other) =>
      other is SessionPreferences &&
      other.template == template &&
      other.rounds == rounds &&
      other.cognitiveSec == cognitiveSec &&
      other.restSec == restSec &&
      other.location == location &&
      other.difficulty == difficulty;

  @override
  int get hashCode => Object.hash(
    template,
    rounds,
    cognitiveSec,
    restSec,
    location,
    difficulty,
  );
}
