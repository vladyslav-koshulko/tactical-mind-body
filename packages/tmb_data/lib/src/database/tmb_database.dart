import 'package:drift/drift.dart';

import '../errors.dart';
import 'schema_versions.dart';
import 'tables.dart';

part 'tmb_database.g.dart';

/// Локальная БД приложения (source of truth, ARCHITECTURE §1).
///
/// Сама БД НЕ открывается здесь: пакет чистый Dart (инвариант 1, файловый ввод-вывод в
/// `lib/` запрещён). Исполнитель запросов [QueryExecutor] передаёт вызывающий:
/// приложение — файловый SQLite, тесты — `NativeDatabase.memory()`.
@DriftDatabase(
  tables: [
    Sessions,
    RoundLogs,
    ExerciseSets,
    TaskAttempts,
    ProfileSettingsTable,
    DisabledCategories,
    ExerciseTargets,
    SessionPreferencesTable,
    UserPacks,
  ],
)
class TmbDatabase extends _$TmbDatabase {
  TmbDatabase(super.e);

  /// Версия схемы БД. Растёт при любом изменении таблиц; одновременно:
  /// `dart run drift_dev schema dump …` и новый `from{N}To{N+1}` в [migration].
  /// Порядок — в комментарии к [migration].
  static const currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  /// Шаблон миграций (SCHEMAS §5: схема Drift версионируется отдельно от JSON).
  ///
  /// Как поднять версию с N до N+1:
  /// 1. Поменять таблицы в `tables.dart`, увеличить [currentSchemaVersion].
  /// 2. `dart run drift_dev schema dump lib/src/database/tmb_database.dart drift_schemas`
  /// 3. `dart run drift_dev schema steps drift_schemas lib/src/database/schema_versions.dart`
  ///    и дописать тело `from{N}To{N+1}` (данные не терять: сырые события
  ///    восстановить нельзя, инвариант 2).
  /// 4. `dart run drift_dev schema generate drift_schemas test/generated_migrations`
  ///    и добавить в `test/migration_test.dart` проверку N → N+1 с данными.
  /// 5. `dart run build_runner build`, затем `dart format .` (CI `*.g.dart` не
  ///    генерирует, файлы коммитятся).
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // БД новее приложения: молча «мигрировать вниз» нельзя, потеряем события.
      if (from > to) throw DatabaseDowngradeException(from: from, to: to);
      await stepByStep()(m, from, to);
    },
    beforeOpen: (details) async {
      if (details.hadUpgrade) {
        final broken = await customSelect('PRAGMA foreign_key_check').get();
        if (broken.isNotEmpty) {
          throw StateError(
            'После миграции ${details.versionBefore} → ${details.versionNow} '
            'нарушена ссылочная целостность (${broken.length} строк).',
          );
        }
      }
      // Каскады и ссылочная целостность событий опираются на FK; в SQLite
      // они выключены по умолчанию и включаются только вне транзакции.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
