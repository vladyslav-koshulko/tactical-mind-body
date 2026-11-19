/// Детерминированный ГПСЧ — SCHEMAS §9, решение 25.
///
/// Вся арифметика — беззнаковая 32-битная с маской `& 0xFFFFFFFF`, без
/// опоры на 64-битное переполнение: на Dart VM `int` — 64 бита, в вебе —
/// 53 бита мантиссы double, а сервер считает на TypeScript. Любой промежуточный
/// результат здесь не превышает 2^34, поэтому он точен и там и там.
/// Никакого `Random()` без сида: одинаковый сид обязан давать одну задачу
/// (инвариант 4).
library;

import 'dart:convert';

const int _mask32 = 0xFFFFFFFF;
const double _two32 = 4294967296;

/// 32-битное умножение по модулю 2^32 (`Math.imul` без знака).
///
/// Операнды делятся на 16-битные половины, чтобы ни одно произведение не
/// вышло за 2^32 (и тем более за 2^53):
/// `a·b mod 2^32 = al·bl + ((ah·bl + al·bh) mod 2^16) · 2^16  (mod 2^32)`.
int imul(int a, int b) {
  final ua = a & _mask32;
  final ub = b & _mask32;
  final ah = ua >>> 16;
  final al = ua & 0xFFFF;
  final bh = ub >>> 16;
  final bl = ub & 0xFFFF;
  final cross = (ah * bl + al * bh) & 0xFFFF;
  return (al * bl + (cross << 16)) & _mask32;
}

/// FNV-1a, 32 бита, по байтам UTF-8 строки: offset `0x811C9DC5`, prime
/// `0x01000193`.
int fnv1a32(String s) {
  var hash = 0x811C9DC5;
  for (final byte in utf8.encode(s)) {
    hash ^= byte;
    hash = imul(hash, 0x01000193);
  }
  return hash;
}

/// Mulberry32 на 32-битной арифметике.
final class Mulberry32 {
  /// Создаёт генератор с готовым 32-битным состоянием.
  Mulberry32(int state) : _state = state & _mask32;

  /// Генератор для задачи: `state = (seed mod 2^32) XOR fnv1a32(taskId)`.
  ///
  /// [seed] — `0 … 2^53−1`; берутся младшие 32 бита.
  factory Mulberry32.forTask({required int seed, required String taskId}) =>
      Mulberry32((seed & _mask32) ^ fnv1a32(taskId));

  int _state;

  /// Текущее 32-битное состояние (для тестов и отладки).
  int get state => _state;

  /// Следующее 32-битное целое без знака, `0 … 2^32−1`.
  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & _mask32;
    var t = imul(_state ^ (_state >>> 15), _state | 1);
    t = ((t + imul(t ^ (t >>> 7), t | 61)) & _mask32) ^ t;
    return (t ^ (t >>> 14)) & _mask32;
  }

  /// Следующее значение в `[0, 1)`.
  double next() => nextUint32() / _two32;

  /// Целое из `[a, b]` включительно: `a + floor(next() · (b − a + 1))`.
  /// Всегда делает ровно один вызов [next].
  int nextIntInRange(int a, int b) {
    if (b < a) throw ArgumentError('b ($b) < a ($a)');
    return a + (next() * (b - a + 1)).floor();
  }
}
