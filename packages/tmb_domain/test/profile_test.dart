import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

void main() {
  group('isCategoryEnabled — граница сегмента', () {
    test('родитель включает потомков', () {
      expect(
        isCategoryEnabled('cog.uncertainty.estimation', {'cog.uncertainty'}),
        isFalse,
      );
      expect(
        isCategoryEnabled('cog.uncertainty', {'cog.uncertainty'}),
        isFalse,
      );
    });

    test('cog.uncertainty НЕ отключает cog.uncertaintyx', () {
      expect(
        isCategoryEnabled('cog.uncertaintyx', {'cog.uncertainty'}),
        isTrue,
      );
      expect(
        isCategoryEnabled('cog.uncertaintyx.estimation', {'cog.uncertainty'}),
        isTrue,
      );
    });

    test('cog.unc не отключает cog.uncertainty', () {
      expect(isCategoryEnabled('cog.uncertainty', {'cog.unc'}), isTrue);
    });

    test('потомок не отключает родителя и соседей', () {
      const disabled = {'cog.uncertainty.premortem'};
      expect(isCategoryEnabled('cog.uncertainty', disabled), isTrue);
      expect(isCategoryEnabled('cog.uncertainty.estimation', disabled), isTrue);
      expect(isCategoryEnabled('cog.uncertainty.premortem', disabled), isFalse);
    });

    test(
      'корневой раздел отключает всё дерево; пустой набор — всё включено',
      () {
        expect(isCategoryEnabled('it.java.generics', {'it'}), isFalse);
        expect(isCategoryEnabled('it.java.generics', const <String>{}), isTrue);
        expect(isCategoryEnabled('cog.speech', {'it'}), isTrue);
      },
    );
  });

  group('цели', () {
    test('defaultTargets по единицам', () {
      expect(DefaultTargets.standard.forUnit(ExerciseUnit.reps).min, 15);
      expect(DefaultTargets.standard.forUnit(ExerciseUnit.seconds).min, 30);
      expect(DefaultTargets.standard.reps.isFixed, isTrue);
    });

    test('прогрессия включена по умолчанию', () {
      expect(const ProfileSettings().progression.enabled, isTrue);
      expect(const ProfileSettings().disabledCategories, isEmpty);
    });
  });
}
