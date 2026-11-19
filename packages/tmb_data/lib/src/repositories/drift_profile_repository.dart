import 'package:drift/drift.dart';
import 'package:tmb_domain/tmb_domain.dart';

import '../database/tmb_database.dart';
import '../errors.dart';
import '../models/session_preferences.dart';
import 'profile_repository.dart';

/// Реализация [ProfileRepository] на Drift.
final class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db);

  final TmbDatabase _db;

  /// `id` единственной строки таблиц-синглтонов (CHECK `id = 1`). Явный: без него
  /// INTEGER PRIMARY KEY получил бы автономер и вторая запись стала бы новой строкой.
  static const _singleRow = 1;

  @override
  Future<ProfileSettings> loadProfile() => _db.transaction(() async {
    final row = await _db.select(_db.profileSettingsTable).getSingleOrNull();
    final disabled = await (_db.select(
      _db.disabledCategories,
    )..orderBy([(t) => OrderingTerm.asc(t.path)])).get();
    final targets = await (_db.select(
      _db.exerciseTargets,
    )..orderBy([(t) => OrderingTerm.asc(t.exerciseId)])).get();
    const defaults = ProfileSettings();
    return ProfileSettings(
      schemaVersion: row?.schemaVersion ?? defaults.schemaVersion,
      disabledCategories: [for (final d in disabled) d.path],
      defaultTargets: row == null
          ? defaults.defaultTargets
          : DefaultTargets(
              reps: TargetRange(
                min: row.defaultRepsMin,
                max: row.defaultRepsMax,
              ),
              seconds: TargetRange(
                min: row.defaultSecondsMin,
                max: row.defaultSecondsMax,
              ),
            ),
      exerciseTargets: [
        for (final t in targets)
          ExerciseTarget(
            exerciseId: t.exerciseId,
            min: t.targetMin,
            max: t.targetMax,
            lockedByUser: t.lockedByUser,
          ),
      ],
      progression: ProgressionSettings(
        enabled: row?.progressionEnabled ?? defaults.progression.enabled,
      ),
    );
  });

  @override
  Stream<ProfileSettings> watchProfile() => _watchTables({
    _db.profileSettingsTable,
    _db.disabledCategories,
    _db.exerciseTargets,
  }, loadProfile);

  @override
  Future<void> saveProfile(
    ProfileSettings settings, {
    Set<String>? installedTaskDomains,
  }) async {
    _requireNonEmptyPool(settings.disabledCategories, installedTaskDomains);
    await _db.transaction(() async {
      await _writeSettingsRow(
        schemaVersion: settings.schemaVersion,
        defaults: settings.defaultTargets,
        progressionEnabled: settings.progression.enabled,
      );
      await _replaceDisabled(settings.disabledCategories);
      await _db.delete(_db.exerciseTargets).go();
      for (final t in settings.exerciseTargets) {
        await _upsertTarget(t);
      }
    });
  }

  @override
  Future<void> setDisabledCategories(
    Iterable<String> paths, {
    Set<String>? installedTaskDomains,
  }) async {
    _requireNonEmptyPool(paths, installedTaskDomains);
    await _db.transaction(() => _replaceDisabled(paths));
  }

  @override
  Future<void> setDefaultTargets(DefaultTargets targets) =>
      _db.transaction(() async {
        await _ensureSettingsRow();
        await _db
            .update(_db.profileSettingsTable)
            .write(
              ProfileSettingsTableCompanion(
                defaultRepsMin: Value(targets.reps.min),
                defaultRepsMax: Value(targets.reps.max),
                defaultSecondsMin: Value(targets.seconds.min),
                defaultSecondsMax: Value(targets.seconds.max),
              ),
            );
      });

  @override
  Future<void> upsertExerciseTarget(ExerciseTarget target) =>
      _upsertTarget(target);

  @override
  Future<bool> removeExerciseTarget(String exerciseId) async {
    final n = await (_db.delete(
      _db.exerciseTargets,
    )..where((t) => t.exerciseId.equals(exerciseId))).go();
    return n > 0;
  }

  @override
  Future<void> setProgressionEnabled({required bool enabled}) =>
      _db.transaction(() async {
        await _ensureSettingsRow();
        await _db
            .update(_db.profileSettingsTable)
            .write(
              ProfileSettingsTableCompanion(progressionEnabled: Value(enabled)),
            );
      });

  @override
  Future<SessionPreferences> loadSessionPreferences() async {
    final row = await _db.select(_db.sessionPreferencesTable).getSingleOrNull();
    if (row == null) return SessionPreferences.standard;
    return SessionPreferences(
      template: parseWire(
        SessionTemplateKind.values,
        row.template,
        'session_preferences.template',
      ),
      rounds: row.rounds,
      cognitiveSec: row.cognitiveSec,
      restSec: row.restSec,
      location: parseWire(
        Location.values,
        row.location,
        'session_preferences.location',
      ),
      difficulty: parseWire(
        DifficultyLevel.values,
        row.difficulty,
        'session_preferences.difficulty',
      ),
    );
  }

  @override
  Stream<SessionPreferences> watchSessionPreferences() =>
      _watchTables({_db.sessionPreferencesTable}, loadSessionPreferences);

  @override
  Future<void> saveSessionPreferences(SessionPreferences p) => _db
      .into(_db.sessionPreferencesTable)
      .insertOnConflictUpdate(
        SessionPreferencesTableCompanion.insert(
          id: const Value(_singleRow),
          template: Value(p.template.wire),
          rounds: Value(p.rounds),
          cognitiveSec: Value(p.cognitiveSec),
          restSec: Value(p.restSec),
          location: Value(p.location.wire),
          difficulty: Value(p.difficulty.wire),
        ),
      );

  // ---- внутреннее ----

  /// Поток значения, пересчитываемого при записи в любую из [tables].
  Stream<T> _watchTables<T>(
    Set<TableInfo<Table, Object?>> tables,
    Future<T> Function() load,
  ) {
    return _db
        .tableUpdates(TableUpdateQuery.onAllTables(tables))
        .asyncMap((_) => load())
        .startWithStream(load);
  }

  void _requireNonEmptyPool(
    Iterable<String> disabled,
    Set<String>? installedDomains,
  ) {
    if (installedDomains == null || installedDomains.isEmpty) return;
    final off = disabled.toSet();
    if (!installedDomains.any((d) => isCategoryEnabled(d, off))) {
      throw const EmptyPoolException();
    }
  }

  Future<void> _ensureSettingsRow() => _db
      .into(_db.profileSettingsTable)
      .insert(
        ProfileSettingsTableCompanion.insert(id: const Value(_singleRow)),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> _writeSettingsRow({
    required int schemaVersion,
    required DefaultTargets defaults,
    required bool progressionEnabled,
  }) => _db
      .into(_db.profileSettingsTable)
      .insertOnConflictUpdate(
        ProfileSettingsTableCompanion.insert(
          id: const Value(_singleRow),
          schemaVersion: Value(schemaVersion),
          defaultRepsMin: Value(defaults.reps.min),
          defaultRepsMax: Value(defaults.reps.max),
          defaultSecondsMin: Value(defaults.seconds.min),
          defaultSecondsMax: Value(defaults.seconds.max),
          progressionEnabled: Value(progressionEnabled),
        ),
      );

  Future<void> _replaceDisabled(Iterable<String> paths) async {
    await _db.delete(_db.disabledCategories).go();
    await _db.batch((b) {
      b.insertAll(_db.disabledCategories, [
        for (final p in paths.toSet())
          DisabledCategoriesCompanion.insert(path: p),
      ]);
    });
  }

  Future<void> _upsertTarget(ExerciseTarget t) => _db
      .into(_db.exerciseTargets)
      .insertOnConflictUpdate(
        ExerciseTargetsCompanion.insert(
          exerciseId: t.exerciseId,
          targetMin: t.min,
          targetMax: t.max,
          lockedByUser: Value(t.lockedByUser),
        ),
      );
}

extension<T> on Stream<T> {
  /// Сначала значение из [load], затем элементы исходного потока.
  Stream<T> startWithStream(Future<T> Function() load) async* {
    yield await load();
    yield* this;
  }
}
