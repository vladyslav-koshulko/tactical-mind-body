import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:uuid/uuid.dart';

import 'session_summary_store.dart';

/// Единственный экземпляр БД на приложение (ARCHITECTURE D8): открывает его
/// приложение, а не `tmb_data`. Закрывается вместе со скоупом.
///
/// В тестах переопределяется на in-memory БД (`NativeDatabase.memory()` из
/// `package:drift/native.dart`); закрытие при dispose нужно повторить в
/// переопределении через `ref.onDispose(db.close)`.
final databaseProvider = Provider<TmbDatabase>((ref) {
  // Web-сборка нужна только для разработки и скриншотов (docs/TESTING.md):
  // sqlite3.wasm и drift_worker.js лежат в apps/mobile/web/.
  final db = TmbDatabase(
    driftDatabase(
      name: 'tmb',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  ref.onDispose(db.close);
  return db;
});

/// Репозиторий сессий. При `finishSession` дополнительно пишет сводку для
/// виджета (`SummaryRecordingSessionRepository`); контроллер об этом не знает.
/// Прерванную сессию контроллер фиксирует сам через `recordSessionSummary`.
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SummaryRecordingSessionRepository(
    DriftSessionRepository(ref.watch(databaseProvider)),
    ref.watch(sessionSummaryStoreProvider),
    onError: reportSummaryError,
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => DriftProfileRepository(ref.watch(databaseProvider)),
);

/// Пользовательские и импортированные паки. Встроенные здесь не живут —
/// см. `contentProvider` в `content_loader.dart`.
final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => DriftContentRepository(ref.watch(databaseProvider)),
);

/// Источник идентификаторов событий: криптослучайный UUID v4 (SCHEMAS §0).
///
/// Живёт на стороне приложения: домен не имеет права на `Random()`
/// (инвариант 4). `Uuid.v4()` по умолчанию берёт `Random.secure()`.
final idSourceProvider = Provider<IdSource>((ref) => const UuidV4IdSource());

/// Часы: мс эпохи UTC. Всё приложение читает время только отсюда, поэтому
/// тесты подменяют его и получают воспроизводимые `startedAt`/`latencyMs`.
final clockProvider = Provider<int Function()>(
  (ref) =>
      () => DateTime.now().toUtc().millisecondsSinceEpoch,
);

/// [IdSource] на пакете `uuid` (криптослучайный генератор).
final class UuidV4IdSource implements IdSource {
  const UuidV4IdSource();

  static const _uuid = Uuid();

  @override
  String nextId() => _uuid.v4();
}
