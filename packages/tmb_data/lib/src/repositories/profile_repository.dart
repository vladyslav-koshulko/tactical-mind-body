import 'package:tmb_domain/tmb_domain.dart';

import '../models/session_preferences.dart';

/// Профиль пользователя: категории (D2), цели и настройки сессии.
abstract interface class ProfileRepository {
  /// Профиль; пока ничего не записано — значения по умолчанию
  /// (`ProfileSettings()`: всё включено, цели 15 повт. / 30 с, прогрессия вкл.).
  /// `disabledCategories` и `exerciseTargets` возвращаются отсортированными.
  Future<ProfileSettings> loadProfile();

  /// Поток профиля: первое значение сразу, затем после каждой записи.
  Stream<ProfileSettings> watchProfile();

  /// Заменяет профиль целиком одной транзакцией.
  ///
  /// [installedTaskDomains] — `domain` всех задач установленных паков (встроенных
  /// и пользовательских). Если задан и ни одна задача не проходит фильтр —
  /// [EmptyPoolException], ничего не записано (`PROF_EMPTY_POOL`). Репозиторий
  /// сам пулы паков не знает, поэтому набор приносит вызывающий.
  Future<void> saveProfile(
    ProfileSettings settings, {
    Set<String>? installedTaskDomains,
  });

  /// Заменяет множество ОТКЛЮЧЁННЫХ путей `domain` (D2). Дубли схлопываются.
  Future<void> setDisabledCategories(
    Iterable<String> paths, {
    Set<String>? installedTaskDomains,
  });

  Future<void> setDefaultTargets(DefaultTargets targets);

  /// Добавляет или заменяет цель упражнения.
  Future<void> upsertExerciseTarget(ExerciseTarget target);

  /// `false` — цели не было.
  Future<bool> removeExerciseTarget(String exerciseId);

  Future<void> setProgressionEnabled({required bool enabled});

  /// Последние параметры сессии; пока не сохранены — [SessionPreferences.standard].
  Future<SessionPreferences> loadSessionPreferences();

  Stream<SessionPreferences> watchSessionPreferences();

  Future<void> saveSessionPreferences(SessionPreferences preferences);
}
