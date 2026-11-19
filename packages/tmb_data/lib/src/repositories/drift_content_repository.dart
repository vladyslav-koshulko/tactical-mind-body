import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tmb_domain/tmb_domain.dart';

import '../database/tmb_database.dart';
import '../errors.dart';
import '../models/installed_pack.dart';
import 'content_repository.dart';

/// Реализация [ContentRepository] на Drift: пак лежит JSON-блобом (`toJson`),
/// рядом — метаданные для списков без разбора блоба.
final class DriftContentRepository implements ContentRepository {
  DriftContentRepository(this._db);

  final TmbDatabase _db;

  @override
  Future<void> installTaskPack(
    TaskPack pack, {
    required int installedAt,
    bool replace = false,
  }) => _install(
    kind: PackKind.taskPack,
    packId: pack.pack,
    source: pack.packSource,
    title: pack.title,
    locale: pack.locale,
    itemCount: pack.items.length,
    installedAt: installedAt,
    json: pack.toJson(),
    replace: replace,
  );

  @override
  Future<void> installExercisePack(
    ExercisePack pack, {
    required int installedAt,
    bool replace = false,
  }) => _install(
    kind: PackKind.exercisePack,
    packId: pack.pack,
    source: pack.packSource,
    title: pack.title,
    locale: pack.defaultLocale,
    itemCount: pack.exercises.length,
    installedAt: installedAt,
    json: pack.toJson(),
    replace: replace,
  );

  Future<void> _install({
    required PackKind kind,
    required String packId,
    required PackSource source,
    required String title,
    required String locale,
    required int itemCount,
    required int installedAt,
    required Map<String, Object?> json,
    required bool replace,
  }) {
    if (source == PackSource.builtin) {
      throw ArgumentError.value(
        source,
        'packSource',
        'встроенные паки лежат в ассетах, в БД — только imported и user',
      );
    }
    return _db.transaction(() async {
      final exists =
          await (_db.select(_db.userPacks)..where(
                (t) => t.kind.equals(kind.wire) & t.packId.equals(packId),
              ))
              .getSingleOrNull();
      if (exists != null && !replace) {
        throw PackAlreadyInstalledException(packId);
      }
      await _db
          .into(_db.userPacks)
          .insertOnConflictUpdate(
            UserPacksCompanion.insert(
              kind: kind.wire,
              packId: packId,
              packSource: source.wire,
              title: title,
              locale: locale,
              itemCount: itemCount,
              installedAt: installedAt,
              content: jsonEncode(json),
            ),
          );
    });
  }

  SimpleSelectStatement<$UserPacksTable, UserPackRow> _allPacks() =>
      _db.select(_db.userPacks)..orderBy([
        (t) => OrderingTerm.asc(t.installedAt),
        (t) => OrderingTerm.asc(t.kind),
        (t) => OrderingTerm.asc(t.packId),
      ]);

  @override
  Future<List<InstalledPack>> listPacks() async =>
      (await _allPacks().get()).map(_meta).toList();

  @override
  Stream<List<InstalledPack>> watchPacks() =>
      _allPacks().watch().map((rows) => rows.map(_meta).toList());

  Future<UserPackRow?> _row(PackKind kind, String packId) =>
      (_db.select(_db.userPacks)
            ..where((t) => t.kind.equals(kind.wire) & t.packId.equals(packId)))
          .getSingleOrNull();

  Future<List<UserPackRow>> _rows(PackKind kind) =>
      (_db.select(_db.userPacks)
            ..where((t) => t.kind.equals(kind.wire))
            ..orderBy([
              (t) => OrderingTerm.asc(t.installedAt),
              (t) => OrderingTerm.asc(t.packId),
            ]))
          .get();

  @override
  Future<TaskPack?> taskPack(String packId) async {
    final row = await _row(PackKind.taskPack, packId);
    return row == null ? null : _taskPack(row);
  }

  @override
  Future<ExercisePack?> exercisePack(String packId) async {
    final row = await _row(PackKind.exercisePack, packId);
    return row == null ? null : _exercisePack(row);
  }

  @override
  Future<List<TaskPack>> taskPacks() async =>
      (await _rows(PackKind.taskPack)).map(_taskPack).toList();

  @override
  Future<List<ExercisePack>> exercisePacks() async =>
      (await _rows(PackKind.exercisePack)).map(_exercisePack).toList();

  @override
  Future<bool> deletePack(PackKind kind, String packId) async {
    final n = await (_db.delete(
      _db.userPacks,
    )..where((t) => t.kind.equals(kind.wire) & t.packId.equals(packId))).go();
    return n > 0;
  }
}

Map<String, Object?> _decode(UserPackRow row) {
  final decoded = jsonDecode(row.content);
  if (decoded is! Map<String, Object?>) {
    throw FormatException('user_packs: «${row.packId}» — корень не объект');
  }
  return decoded;
}

TaskPack _taskPack(UserPackRow row) => TaskPack.fromJson(_decode(row));

ExercisePack _exercisePack(UserPackRow row) =>
    ExercisePack.fromJson(_decode(row));

InstalledPack _meta(UserPackRow r) => InstalledPack(
  kind: parseWire(PackKind.values, r.kind, 'user_packs.kind'),
  packId: r.packId,
  packSource: parseWire(
    PackSource.values,
    r.packSource,
    'user_packs.pack_source',
  ),
  title: r.title,
  locale: r.locale,
  itemCount: r.itemCount,
  installedAt: r.installedAt,
);
