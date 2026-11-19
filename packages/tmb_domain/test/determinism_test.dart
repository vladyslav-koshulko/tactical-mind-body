import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

// Эталонные значения посчитаны НЕЗАВИСИМОЙ реализацией на Python
// (python3 -I, bigint-арифметика с маской 2^32), а не этим Dart-кодом.
void main() {
  group('imul', () {
    test('совпадает с (a*b) mod 2^32', () {
      expect(imul(0xFFFFFFFF, 0xFFFFFFFF), 1);
      expect(imul(0x12345678, 0x9ABCDEF0), 606937216);
      expect(imul(0x811C9DC5, 0x01000193), 84696351);
      expect(imul(0xDEADBEEF, 0xCAFEBABE), 2295290722);
    });
  });

  group('fnv1a32', () {
    test('вектор unc.rs.001', () {
      expect(fnv1a32('unc.rs.001'), 2479740597);
    });
    test('пустая строка, ASCII, кириллица (UTF-8)', () {
      expect(fnv1a32(''), 2166136261);
      expect(fnv1a32('a'), 3826002220);
      expect(fnv1a32('привет'), 2168984447);
    });
  });

  group('Mulberry32', () {
    test('начальное состояние = (seed mod 2^32) XOR fnv1a32(taskId)', () {
      final rng = Mulberry32.forTask(seed: 12345, taskId: 'unc.rs.001');
      expect(rng.state, 2479744652);
    });

    test('первые пять значений seed=12345, taskId=unc.rs.001', () {
      final rng = Mulberry32.forTask(seed: 12345, taskId: 'unc.rs.001');
      final raw = [for (var i = 0; i < 5; i++) rng.nextUint32()];
      expect(raw, [404183234, 3781130474, 3731527651, 3763876779, 4171960635]);

      final rng2 = Mulberry32.forTask(seed: 12345, taskId: 'unc.rs.001');
      final values = [for (var i = 0; i < 5; i++) rng2.next()];
      expect(values[0], closeTo(0.0941062425263226, 1e-15));
      expect(values[1], closeTo(0.8803630420006812, 1e-15));
      expect(values[2], closeTo(0.8688139847945422, 1e-15));
      expect(values[3], closeTo(0.8763458530884236, 1e-15));
      expect(values[4], closeTo(0.9713602799456567, 1e-15));
      expect(values, everyElement(allOf(greaterThanOrEqualTo(0), lessThan(1))));
    });

    test('граничные сиды: 0 и 2^53-1', () {
      final a = Mulberry32.forTask(seed: 0, taskId: 'unc.rs.001');
      expect(
        [for (var i = 0; i < 3; i++) a.nextUint32()],
        [3197639996, 1813921918, 3621645814],
      );
      final b = Mulberry32.forTask(
        seed: 9007199254740991,
        taskId: 'unc.rs.001',
      );
      expect(
        [for (var i = 0; i < 3; i++) b.nextUint32()],
        [381645982, 1573684896, 147626710],
      );
    });

    test('сид берётся по модулю 2^32', () {
      final a = Mulberry32.forTask(seed: 4294967303, taskId: 'unc.rs.001');
      expect(
        [for (var i = 0; i < 3; i++) a.nextUint32()],
        [1062501765, 4292880187, 2249224019],
      );
      final b = Mulberry32.forTask(seed: 7, taskId: 'unc.rs.001');
      final c = Mulberry32.forTask(seed: 4294967303, taskId: 'unc.rs.001');
      expect(c.nextUint32(), b.nextUint32());
    });

    test('целое из [a, b] включительно', () {
      final rng = Mulberry32.forTask(seed: 12345, taskId: 'unc.rs.001');
      // Python: 18 + floor(next() * 15) для тех же пяти значений.
      expect(
        [for (var i = 0; i < 5; i++) rng.nextIntInRange(18, 32)],
        [19, 31, 31, 31, 32],
      );
      expect(() => rng.nextIntInRange(5, 4), throwsArgumentError);
      final fixed = Mulberry32(1);
      expect(fixed.nextIntInRange(7, 7), 7);
    });

    test('разные сиды дают разброс', () {
      final firsts = {
        for (var s = 0; s < 200; s++)
          Mulberry32.forTask(seed: s, taskId: 'x.y.z').nextUint32(),
      };
      expect(firsts.length, greaterThan(190));
    });
  });

  group('cueMoments', () {
    const cues = [
      Cue(fromSec: 18, toSec: 32, text: 'a'),
      Cue(fromSec: 40, toSec: 40, text: 'b'),
      Cue(fromSec: 50, toSec: 55, text: 'c'),
    ];

    test('i-я подсказка = i-й вызов next()', () {
      final m = cueMoments(seed: 12345, taskId: 'unc.rs.001', cues: cues);
      final rng = Mulberry32.forTask(seed: 12345, taskId: 'unc.rs.001');
      expect(m[0], 18 + (rng.next() * 15).floor());
      expect(m[1], 40); // вырожденный диапазон всё равно расходует вызов
      expect(m[2], 50 + (rng.next() * 6).floor());
      // Первая — из вектора Python: 18 + floor(0.0941 * 15) = 19.
      expect(m[0], 19);
    });

    test('добавление подсказки в конец не меняет предыдущие', () {
      final short = cueMoments(
        seed: 99,
        taskId: 'unc.rs.001',
        cues: cues.sublist(0, 2),
      );
      final long = cueMoments(seed: 99, taskId: 'unc.rs.001', cues: cues);
      expect(long.sublist(0, 2), short);
    });

    test('детерминизм и разброс по сидам', () {
      List<int> at(int s) =>
          cueMoments(seed: s, taskId: 'unc.rs.001', cues: cues);
      expect(at(5), at(5));
      final firsts = {for (var s = 0; s < 100; s++) at(s)[0]};
      expect(firsts.length, greaterThan(5));
      expect(firsts, everyElement(inInclusiveRange(18, 32)));
    });
  });
}
