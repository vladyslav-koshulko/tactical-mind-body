import '../common/enums.dart';
import '../common/json_reader.dart';

/// Сессия тренировки (SCHEMAS §3.1). Время — мс эпохи UTC.
final class Session {
  const Session({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.utcOffsetMin,
    required this.location,
    required this.difficulty,
    required this.template,
    required this.appVersion,
  });

  factory Session.fromJson(Map<String, Object?> json) =>
      Session.read(readRoot(json));

  factory Session.read(JsonObj o) => Session(
    id: o.string('id'),
    startedAt: o.integer('startedAt'),
    endedAt: o.integerN('endedAt'),
    utcOffsetMin: o.integer('utcOffsetMin'),
    location: o.enumValue('location', Location.values),
    difficulty: o.enumValue('difficulty', DifficultyLevel.values),
    template: o.enumValue('template', SessionTemplateKind.values),
    appVersion: o.string('appVersion'),
  );

  /// UUID v4.
  final String id;
  final int startedAt;

  /// `null` — сессия не завершена (прервана, приложение убито).
  final int? endedAt;

  /// Смещение локального пояса на момент старта, минуты.
  final int utcOffsetMin;
  final Location location;
  final DifficultyLevel difficulty;
  final SessionTemplateKind template;
  final String appVersion;

  Map<String, Object?> toJson() => {
    'id': id,
    'startedAt': startedAt,
    'endedAt': endedAt,
    'utcOffsetMin': utcOffsetMin,
    'location': location.wire,
    'difficulty': difficulty.wire,
    'template': template.wire,
    'appVersion': appVersion,
  };
}
