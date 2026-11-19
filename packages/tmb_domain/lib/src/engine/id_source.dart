import '../determinism/mulberry32.dart';

/// Источник UUID v4 для записей событий (SCHEMAS §0: id генерируются на
/// клиенте).
///
/// Движок — чистая функция от входов и не имеет права обращаться к `Random()`
/// (инвариант 4 и граница пакета), поэтому генератор идентификаторов
/// передаёт хост: в приложении — криптослучайный UUID v4, в тестах и при
/// воспроизведении сессии — [SeededIdSource].
abstract interface class IdSource {
  /// Следующий уникальный идентификатор: строчный UUID v4.
  String nextId();
}

/// Детерминированный источник UUID v4 на Mulberry32: одинаковый сид →
/// одинаковая последовательность идентификаторов.
///
/// Для тестов, воспроизведения и «сухих прогонов». Состояние ГПСЧ — 32 бита,
/// поэтому последовательность повторяется после ~2^30 вызовов; для хранения
/// реальных данных хосту нужен криптослучайный источник.
final class SeededIdSource implements IdSource {
  SeededIdSource(int seed)
    : _rng = Mulberry32.forTask(seed: seed, taskId: 'tmb.engine.ids');

  final Mulberry32 _rng;

  @override
  String nextId() {
    final bytes = List<int>.filled(16, 0);
    for (var i = 0; i < 4; i++) {
      final w = _rng.nextUint32();
      bytes[i * 4] = (w >>> 24) & 0xFF;
      bytes[i * 4 + 1] = (w >>> 16) & 0xFF;
      bytes[i * 4 + 2] = (w >>> 8) & 0xFF;
      bytes[i * 4 + 3] = w & 0xFF;
    }
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // версия 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // вариант RFC 4122
    final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
    return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-'
        '${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-'
        '${hex.sublist(10).join()}';
  }
}
