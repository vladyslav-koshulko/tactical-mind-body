import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:test/test.dart';
import 'package:tmb_data/tmb_data.dart';

import 'generated_migrations/schema.dart';
import 'support/fixtures.dart';

/// Кладёт события «как их писала версия N» через сырой SQL: после миграции они
/// обязаны остаться на месте (сырые события не восстановить, инвариант 2).
///
/// При повышении `schemaVersion` СЮДА добавляется запись для новой версии —
/// иначе тест ниже упадёт и напомнит об этом.
final Map<int, void Function(raw.Database db)> _seedByVersion = {
  1: (db) {
    db.execute(
      'INSERT INTO sessions (id, started_at, ended_at, utc_offset_min, '
      'location, difficulty, template, app_version) '
      "VALUES ('${uuid(1)}', 1000, 2000, 180, 'HOME', 'fighter', "
      "'dual_task', '0.1.0+1')",
    );
    db.execute(
      'INSERT INTO task_attempts (id, session_id, block_index, round_index, '
      'task_id, pack_id, pack_source, archetype, domain, difficulty, seed, '
      'status, presented_at, answered_at, latency_ms, is_correct, '
      'self_rating, response, encoded_round_index, payload_hash) '
      "VALUES ('${uuid(2)}', '${uuid(1)}', 1, 0, 'demo.java.002', 'demo.ru', "
      "'builtin', 'choice', 'it.java', 0.3, 1234567890, 'answered', 1100, "
      "1200, 100, 1, NULL, '2', NULL, '${hash(2)}')",
    );
  },
};

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('в тесте есть схемы всех версий вплоть до текущей', () {
    expect(
      GeneratedHelper.versions,
      List.generate(TmbDatabase.currentSchemaVersion, (i) => i + 1),
      reason:
          'После смены schemaVersion: drift_dev schema dump + '
          'schema generate (см. комментарий к TmbDatabase.migration).',
    );
  });

  test(
    'схема, созданная кодом, совпадает с ожидаемой (validateDatabaseSchema)',
    () async {
      final db = TmbDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      // Любой запрос открывает БД и запускает onCreate.
      await db.select(db.sessions).get();
      await db.validateDatabaseSchema();
    },
  );

  test(
    'createAll даёт ровно ту схему, что зафиксирована дампом текущей версии',
    () async {
      final schema = await verifier.schemaAt(TmbDatabase.currentSchemaVersion);
      final db = TmbDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, TmbDatabase.currentSchemaVersion);
    },
  );

  // От каждой старой версии до текущей: схема совпадает, данные на месте.
  for (var from = 1; from <= TmbDatabase.currentSchemaVersion; from++) {
    test(
      'миграция v$from → v${TmbDatabase.currentSchemaVersion}: схема и события',
      () async {
        final seed = _seedByVersion[from];
        expect(seed, isNotNull, reason: 'нет посева данных для v$from');

        final schema = await verifier.schemaAt(from);
        seed!(schema.rawDatabase);

        final db = TmbDatabase(schema.newConnection());
        addTearDown(db.close);
        await verifier.migrateAndValidate(db, TmbDatabase.currentSchemaVersion);

        final repo = DriftSessionRepository(db);
        final session = (await repo.getSession(uuid(1)))!;
        expect(session.endedAt, 2000);
        final attempt = (await repo.attemptsOf(uuid(1))).single;
        expect(attempt.latencyMs, 100);
        expect(attempt.isCorrect, isTrue);
        expect(attempt.payloadHash, hash(2));
      },
    );
  }

  test('после миграции внешние ключи включены и каскад работает', () async {
    final schema = await verifier.schemaAt(1);
    _seedByVersion[1]!(schema.rawDatabase);
    final db = TmbDatabase(schema.newConnection());
    addTearDown(db.close);
    final repo = DriftSessionRepository(db);
    expect(await repo.deleteSession(uuid(1)), isTrue);
    expect(await db.select(db.taskAttempts).get(), isEmpty);
  });

  test('БД новее приложения: молчаливый «даунгрейд» запрещён', () async {
    final schema = await verifier.schemaAt(1);
    // Файл БД помечен версией из будущего.
    schema.rawDatabase.execute(
      'PRAGMA user_version = ${TmbDatabase.currentSchemaVersion + 1}',
    );
    final db = TmbDatabase(schema.newConnection());
    addTearDown(db.close);
    await expectLater(
      db.select(db.sessions).get(),
      throwsA(isA<DatabaseDowngradeException>()),
    );
  });
}
