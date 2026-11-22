import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

/// Ключ единственной записи — JSON `SessionSummarySnapshot` строкой.
///
/// На Android плагин кладёт её в файл `FlutterSharedPreferences` под ключом
/// `flutter.tmb.last_session_summary` (префикс `flutter.` добавляет плагин) —
/// так её сможет прочитать нативный виджет. Менять имя нельзя: оно часть
/// контракта с виджетом (ARCHITECTURE «Сводка сессии для виджета»).
const sessionSummaryKey = 'tmb.last_session_summary';

/// [SessionSummaryStore] поверх `shared_preferences` — простое key-value
/// хранилище, доступное нативному коду. Нечитаемая запись (битый JSON,
/// версия новее известной) для читателя — «нет сводки», а не ошибка.
final class SharedPreferencesSessionSummaryStore
    implements SessionSummaryStore {
  /// [prefs] подменяется в тестах; по умолчанию — `SharedPreferences.getInstance`.
  SharedPreferencesSessionSummaryStore({
    Future<SharedPreferences> Function()? prefs,
  }) : _prefs = prefs ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _prefs;

  @override
  Future<void> write(SessionSummarySnapshot snapshot) async {
    final prefs = await _prefs();
    await prefs.setString(sessionSummaryKey, jsonEncode(snapshot.toJson()));
  }

  @override
  Future<SessionSummarySnapshot?> read() async {
    final prefs = await _prefs();
    final raw = prefs.getString(sessionSummaryKey);
    if (raw == null) return null;
    try {
      return SessionSummarySnapshot.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } on Object {
      // FormatException или чужой тип: для читателя это «нет сводки».
      return null;
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(sessionSummaryKey);
  }
}

/// Общее хранилище последней сводки. В тестах переопределяется на
/// `InMemorySessionSummaryStore` (см. `test/helpers.dart`).
final sessionSummaryStoreProvider = Provider<SessionSummaryStore>(
  (ref) => SharedPreferencesSessionSummaryStore(),
);

/// Сбой записи сводки не должен ронять тренировку: сводка — производная
/// витрина, БД — источник правды. Ошибка только репортится.
void reportSummaryError(Object error, StackTrace stack) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'tmb session summary',
      context: ErrorDescription('запись сводки сессии для виджета'),
    ),
  );
}
