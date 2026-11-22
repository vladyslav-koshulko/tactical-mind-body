import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/features/session/session_format.dart';
import 'package:tmb_mobile/features/session/session_services.dart';
import 'package:tmb_mobile/features/session/task_order.dart';

final class _MaxRandom implements Random {
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 0.999;
  @override
  int nextInt(int max) => max - 1;
}

void main() {
  group('shuffledOrder', () {
    test('перестановка всех индексов', () {
      for (var n = 0; n < 9; n++) {
        final order = shuffledOrder(n, seed: 5, taskId: 't');
        expect(order.toList()..sort(), List.generate(n, (i) => i));
      }
    });

    test('детерминирован: сид и задача решают порядок (инвариант 4)', () {
      final a = shuffledOrder(8, seed: 123, taskId: 'task.a');
      expect(shuffledOrder(8, seed: 123, taskId: 'task.a'), a);
      final others = {
        for (var seed = 0; seed < 20; seed++)
          shuffledOrder(8, seed: seed, taskId: 'task.a').join(','),
      };
      expect(others.length, greaterThan(10)); // сид действительно влияет
      expect(shuffledOrder(8, seed: 123, taskId: 'task.b'), isNot(a));
    });

    test('mustDiffer: никогда не исходный порядок', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final n in [2, 3, 5]) {
          final order = shuffledOrder(
            n,
            seed: seed,
            taskId: 'o',
            mustDiffer: true,
          );
          expect(order, isNot(List.generate(n, (i) => i)));
        }
      }
    });
  });

  group('isNumericAnswer', () {
    test('число и числоподобная строка — клавиатура, слово — поле', () {
      expect(isNumericAnswer(85), isTrue);
      expect(isNumericAnswer(3.5), isTrue);
      expect(isNumericAnswer('355,8'), isTrue);
      expect(isNumericAnswer('купол'), isFalse);
      expect(isNumericAnswer('Б-3'), isFalse);
    });
  });

  group('generateSessionSeed', () {
    test('в допустимом диапазоне 0 … 2^53 − 1', () {
      expect(generateSessionSeed(_MaxRandom()), maxTaskSeed);
      final random = Random.secure();
      for (var i = 0; i < 200; i++) {
        final seed = generateSessionSeed(random);
        expect(seed, inInclusiveRange(0, maxTaskSeed));
        TaskSeed(seed); // не бросает
      }
    });
  });

  group('formatMmSs', () {
    test('округляет вверх, минуты не ограничены', () {
      expect(formatMmSs(0), '00:00');
      expect(formatMmSs(-5), '00:00');
      expect(formatMmSs(1), '00:01');
      expect(formatMmSs(1000), '00:01');
      expect(formatMmSs(1001), '00:02');
      expect(formatMmSs(65000), '01:05');
      expect(formatMmSs(3600000), '60:00');
    });
  });
}
