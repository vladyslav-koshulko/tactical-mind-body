import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

import '../../data/content_loader.dart';
import '../../data/providers.dart';
import 'category_catalog.dart';
import 'file_share_service.dart';

/// Профиль пользователя (категории, цели, прогрессия). Поток: экран
/// перерисовывается сам после каждой записи.
final profileProvider = StreamProvider<ProfileSettings>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);

/// Последние параметры сессии (шаблон, круги, окно, локация, сложность).
final sessionPreferencesProvider = StreamProvider<SessionPreferences>(
  (ref) => ref.watch(profileRepositoryProvider).watchSessionPreferences(),
);

/// Паки задач (встроенные + установленные) — из `taskSourcesProvider`, чтобы
/// экран видел ровно то, из чего `SessionPlanner` строит пул.
final taskPacksProvider = FutureProvider<List<TaskPack>>((ref) async {
  final sources = await ref.watch(taskSourcesProvider.future);
  return [
    for (final s in sources)
      if (s.provider case final PackTaskProvider p) p.pack,
  ];
});

/// Каталог категорий: два раздела, иерархия, число задач.
final categoryCatalogProvider = FutureProvider<CategoryCatalog>((ref) async {
  return CategoryCatalog.build(await ref.watch(taskPacksProvider.future));
});

/// Платформенный «Поделиться». В тестах подменяется фейком.
final fileShareServiceProvider = Provider<FileShareService>(
  (ref) => const SharePlusFileShareService(),
);

/// Запись настроек. Все записи идут по очереди и читают свежее значение из
/// БД перед изменением, поэтому быстрые нажатия подряд не затирают друг друга.
final settingsWriterProvider = Provider<SettingsWriter>(
  (ref) => SettingsWriter(ref.watch(profileRepositoryProvider)),
);

final class SettingsWriter {
  SettingsWriter(this._repo);

  final ProfileRepository _repo;
  Future<void> _tail = Future<void>.value();

  Future<T> _enqueue<T>(Future<T> Function() job) {
    final result = _tail.then((_) => job());
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<void> updatePreferences(
    SessionPreferences Function(SessionPreferences current) change,
  ) => _enqueue(() async {
    final current = await _repo.loadSessionPreferences();
    await _repo.saveSessionPreferences(change(current));
  });

  Future<void> updateDefaultTargets(
    DefaultTargets Function(DefaultTargets current) change,
  ) => _enqueue(() async {
    final profile = await _repo.loadProfile();
    await _repo.setDefaultTargets(change(profile.defaultTargets));
  });

  Future<void> setProgressionEnabled({required bool enabled}) =>
      _enqueue(() => _repo.setProgressionEnabled(enabled: enabled));

  Future<void> saveExerciseTarget(ExerciseTarget target) =>
      _enqueue(() => _repo.upsertExerciseTarget(target));

  Future<void> resetExerciseTarget(String exerciseId) =>
      _enqueue(() => _repo.removeExerciseTarget(exerciseId));

  /// Включает/выключает категории [targets]. Бросает [EmptyPoolException],
  /// если после изменения не останется ни одной включённой категории: ничего
  /// не записано.
  Future<void> setCategoriesEnabled({
    required Iterable<String> targets,
    required bool enabled,
    required Set<String> known,
  }) => _enqueue(() async {
    final profile = await _repo.loadProfile();
    final next = disabledAfter(
      disabled: profile.disabledCategories,
      known: known,
      targets: targets,
      enable: enabled,
    );
    await _repo.setDisabledCategories(next, installedTaskDomains: known);
  });
}
