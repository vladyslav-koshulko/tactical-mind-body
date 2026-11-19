/// Таблицы Drift (схема БД v1). Без Flutter.
///
/// Перечисления лежат строками в «проводном» виде (`WireEnum.wire`), как в
/// JSON-экспорте: имя Dart-идентификатора не должно влиять на то, что записано
/// на диск. Преобразование — в репозиториях.
///
/// CHECK-ограничения дублируют числовые правила SCHEMAS §3/§4: сырое событие с
/// битым полем — ошибка записи, а не «пустое значение» (инвариант 2). Закрытые
/// списки (`location`, `archetype`…) в CHECK не дублируются: их расширение не
/// должно требовать миграции схемы БД.
library;

import 'package:drift/drift.dart';

/// Сессия тренировки (SCHEMAS §3.1).
@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  IntColumn get startedAt => integer()();

  /// `NULL` — сессия прервана (приложение убито).
  IntColumn get endedAt => integer().nullable()();
  IntColumn get utcOffsetMin => integer()();
  TextColumn get location => text()();
  TextColumn get difficulty => text()();
  TextColumn get template => text()();
  TextColumn get appVersion => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (ended_at IS NULL OR ended_at >= started_at)',
    'CHECK (utc_offset_min BETWEEN -720 AND 840)',
  ];
}

/// Один физический круг (SCHEMAS §3.2).
@DataClassName('RoundLogRow')
@TableIndex(name: 'idx_round_logs_session', columns: {#sessionId})
class RoundLogs extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get blockIndex => integer()();
  IntColumn get roundIndex => integer()();
  IntColumn get durationMs => integer()();

  /// 1 легко, 2 нормально, 3 тяжело; `NULL` — не оценил.
  IntColumn get rpe => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (block_index >= 0 AND round_index >= 0 AND duration_ms >= 0)',
    'CHECK (rpe IS NULL OR rpe BETWEEN 1 AND 3)',
  ];
}

/// Одно упражнение в круге (SCHEMAS §3.3). Источник истории для прогрессии.
@DataClassName('ExerciseSetRow')
@TableIndex(name: 'idx_exercise_sets_session', columns: {#sessionId})
@TableIndex(name: 'idx_exercise_sets_round', columns: {#roundId})
@TableIndex(
  name: 'idx_exercise_sets_exercise_time',
  columns: {#exerciseId, #startedAt},
)
class ExerciseSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get roundId =>
      text().references(RoundLogs, #id, onDelete: KeyAction.cascade)();
  IntColumn get setIndex => integer()();
  TextColumn get exerciseId => text()();
  TextColumn get unit => text()();

  /// План, зафиксированный при старте сессии (D6).
  IntColumn get prescribed => integer()();
  IntColumn get done => integer()();
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (set_index >= 0)',
    'CHECK (prescribed BETWEEN 1 AND 3600)',
    'CHECK (done BETWEEN 0 AND 3600)',
    'CHECK (ended_at >= started_at)',
  ];
}

/// Когнитивная попытка — сырое событие, не агрегат (инвариант 2, SCHEMAS §3.4).
@DataClassName('TaskAttemptRow')
@TableIndex(name: 'idx_task_attempts_session', columns: {#sessionId})
@TableIndex(name: 'idx_task_attempts_pack', columns: {#packId, #taskId})
class TaskAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get blockIndex => integer()();
  IntColumn get roundIndex => integer()();
  TextColumn get taskId => text()();
  TextColumn get packId => text()();
  TextColumn get packSource => text()();
  TextColumn get archetype => text()();
  TextColumn get domain => text()();
  RealColumn get difficulty => real()();

  /// `0 … 2^53−1` — помещается в INTEGER SQLite (64 бита) без потерь.
  IntColumn get seed => integer()();
  TextColumn get status => text()();
  IntColumn get presentedAt => integer()();
  IntColumn get answeredAt => integer().nullable()();
  IntColumn get latencyMs => integer().nullable()();

  /// `NULL` — непроверяемая задача (`verbal`).
  BoolColumn get isCorrect => boolean().nullable()();
  IntColumn get selfRating => integer().nullable()();
  TextColumn get response => text().nullable()();
  IntColumn get encodedRoundIndex => integer().nullable()();
  TextColumn get payloadHash => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (block_index >= 0 AND round_index >= 0)',
    'CHECK (difficulty BETWEEN 0 AND 1)',
    'CHECK (seed BETWEEN 0 AND 9007199254740991)',
    "CHECK (status IN ('answered', 'timeout', 'skipped'))",
    // answeredAt/latencyMs заполнены тогда и только тогда, когда status = answered.
    "CHECK ((status = 'answered') = (answered_at IS NOT NULL))",
    "CHECK ((status = 'answered') = (latency_ms IS NOT NULL))",
    'CHECK (latency_ms IS NULL OR latency_ms >= 0)',
    'CHECK (answered_at IS NULL OR answered_at >= presented_at)',
    'CHECK (self_rating IS NULL OR self_rating BETWEEN 0 AND 3)',
    'CHECK (encoded_round_index IS NULL OR '
        '(encoded_round_index >= 0 AND encoded_round_index <= round_index))',
    'CHECK (length(payload_hash) = 64)',
  ];
}

/// Одна строка (`id = 1`): профиль без списков (SCHEMAS §4).
@DataClassName('ProfileSettingsRow')
class ProfileSettingsTable extends Table {
  @override
  String get tableName => 'profile_settings';

  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  IntColumn get defaultRepsMin => integer().withDefault(const Constant(15))();
  IntColumn get defaultRepsMax => integer().withDefault(const Constant(15))();
  IntColumn get defaultSecondsMin =>
      integer().withDefault(const Constant(30))();
  IntColumn get defaultSecondsMax =>
      integer().withDefault(const Constant(30))();
  BoolColumn get progressionEnabled =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (id = 1)',
    'CHECK (default_reps_min >= 1 AND default_reps_min <= default_reps_max '
        'AND default_reps_max <= 3600)',
    'CHECK (default_seconds_min >= 1 AND default_seconds_min <= '
        'default_seconds_max AND default_seconds_max <= 3600)',
  ];
}

/// Множество ОТКЛЮЧЁННЫХ путей `domain` (D2). Нет строки — категория включена.
@DataClassName('DisabledCategoryRow')
class DisabledCategories extends Table {
  TextColumn get path => text()();

  @override
  Set<Column> get primaryKey => {path};
}

/// Цели по упражнениям (SCHEMAS §4 `ExerciseTarget`).
@DataClassName('ExerciseTargetRow')
class ExerciseTargets extends Table {
  TextColumn get exerciseId => text()();
  IntColumn get targetMin => integer()();
  IntColumn get targetMax => integer()();
  BoolColumn get lockedByUser => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {exerciseId};

  @override
  List<String> get customConstraints => [
    'CHECK (target_min >= 1 AND target_min <= target_max '
        'AND target_max <= 3600)',
  ];
}

/// Одна строка (`id = 1`): последние выбранные параметры сессии.
@DataClassName('SessionPreferencesRow')
class SessionPreferencesTable extends Table {
  @override
  String get tableName => 'session_preferences';

  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get template => text().withDefault(const Constant('dual_task'))();
  IntColumn get rounds => integer().withDefault(const Constant(5))();
  IntColumn get cognitiveSec => integer().withDefault(const Constant(180))();
  IntColumn get restSec => integer().withDefault(const Constant(0))();
  TextColumn get location => text().withDefault(const Constant('HOME'))();
  TextColumn get difficulty => text().withDefault(const Constant('recruit'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (id = 1)',
    'CHECK (rounds >= 1 AND cognitive_sec >= 0 AND rest_sec >= 0)',
  ];
}

/// Пользовательские и импортированные паки (D5): JSON-блоб и метаданные.
///
/// Встроенные паки (`builtin`) сюда не попадают — они лежат в ассетах.
/// Пак — единица удаления: откат целиком одной строкой.
@DataClassName('UserPackRow')
class UserPacks extends Table {
  /// `task_pack` | `exercise_pack`.
  TextColumn get kind => text()();

  /// Поле `pack` документа.
  TextColumn get packId => text()();

  /// `imported` | `user`; присваивает тот, кто пак установил (решение 10).
  TextColumn get packSource => text()();
  TextColumn get title => text()();

  /// `locale` пака задач или `defaultLocale` пака упражнений.
  TextColumn get locale => text()();
  IntColumn get itemCount => integer()();
  IntColumn get installedAt => integer()();

  /// Канонический JSON документа (`toJson`), `kind` и `schemaVersion` внутри.
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {kind, packId};

  @override
  List<String> get customConstraints => [
    "CHECK (kind IN ('task_pack', 'exercise_pack'))",
    "CHECK (pack_source IN ('imported', 'user'))",
  ];
}
