import 'dart:io';

import 'package:test/test.dart';

/// Инвариант 1 и граница пакета: движок — чистый Dart без часов, таймеров,
/// Future/Stream и случайности (время подаёт хост, инвариант 4).
void main() {
  test('в коде движка нет Flutter, dart:io/ui/async, часов и Random', () {
    final forbidden = RegExp(
      r'package:flutter|dart:io|dart:ui|dart:async|dart:math'
      r'|DateTime\.now|Stopwatch|\bTimer\b|\bFuture\b|\bStream\b|\bRandom\b'
      r'|\basync\b|\bawait\b',
    );
    final files = Directory('lib/src/engine')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    expect(files, isNotEmpty);
    for (final file in files) {
      for (final (i, line) in file.readAsLinesSync().indexed) {
        final code = line.split('//').first;
        expect(
          forbidden.hasMatch(code),
          isFalse,
          reason: '${file.path}:${i + 1}: $line',
        );
      }
    }
  });
}
