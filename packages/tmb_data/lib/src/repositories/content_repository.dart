import 'package:tmb_domain/tmb_domain.dart';

import '../models/installed_pack.dart';

/// Пользовательские и импортированные паки (D5). Встроенные паки (`builtin`)
/// лежат в ассетах и сюда не попадают: [ArgumentError].
///
/// Репозиторий хранит уже **проверенные** паки: валидатор (до записи, лимиты,
/// предпросмотр, дедупликация по хешу) — забота вызывающего (D5).
abstract interface class ContentRepository {
  /// Устанавливает пак задач. Если пак с таким `pack` уже есть и [replace]
  /// не задан — [PackAlreadyInstalledException].
  Future<void> installTaskPack(
    TaskPack pack, {
    required int installedAt,
    bool replace = false,
  });

  Future<void> installExercisePack(
    ExercisePack pack, {
    required int installedAt,
    bool replace = false,
  });

  /// Метаданные всех установленных паков, по `installedAt`, затем по `packId`.
  Future<List<InstalledPack>> listPacks();

  Stream<List<InstalledPack>> watchPacks();

  Future<TaskPack?> taskPack(String packId);
  Future<ExercisePack?> exercisePack(String packId);

  /// Все установленные паки задач (для сборки пула и `PROF_EMPTY_POOL`).
  Future<List<TaskPack>> taskPacks();
  Future<List<ExercisePack>> exercisePacks();

  /// Откат пака целиком одним действием (D5). `false` — пака нет.
  Future<bool> deletePack(PackKind kind, String packId);
}
