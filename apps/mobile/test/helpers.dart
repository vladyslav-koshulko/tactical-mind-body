import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/data/session_summary_store.dart';

/// Мс эпохи для фейковых часов: 2026-01-01T00:00:00Z.
const fakeNowMs = 1767225600000;

/// БД в памяти; закрывается вместе со скоупом.
final inMemoryDatabaseOverride = databaseProvider.overrideWith((ref) {
  final db = TmbDatabase(NativeDatabase.memory());
  ref.onDispose(db.close);
  return db;
});

/// Стандартный набор переопределений для тестов приложения: БД в памяти,
/// хранилище сводки в памяти и управляемые часы.
List<Override> testOverrides({int Function()? clock}) => [
  inMemoryDatabaseOverride,
  sessionSummaryStoreProvider.overrideWithValue(InMemorySessionSummaryStore()),
  clockProvider.overrideWithValue(clock ?? () => fakeNowMs),
];
