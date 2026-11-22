import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/settings/targets_screen.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

import 'settings_test_support.dart';

final _l10n = AppLocalizationsRu();

Future<ProfileSettings> _profile(WidgetTester tester, ProviderContainer c) =>
    db(tester, () => c.read(profileRepositoryProvider).loadProfile());

Future<Exercise> _first(WidgetTester tester, ProviderContainer c) async {
  final content = await db(tester, () => c.read(contentProvider.future));
  return content.exercises.first;
}

String _name(Exercise e) => e.name['ru']!;

void main() {
  group('цели упражнений', () {
    testWidgets('все упражнения базы в списке; по умолчанию — из настроек', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const TargetsScreen());
      final content = await db(tester, () => c.read(contentProvider.future));
      expect(content.exercises, isNotEmpty);

      final first = content.exercises.first;
      expect(find.text(_name(first)), findsOneWidget);
      // Цель по умолчанию — 15 повторений; отмечена как «по умолчанию».
      expect(
        find.text(_l10n.targetsValueFixed(15, _l10n.targetsUnitReps)),
        findsWidgets,
      );
      expect(find.text(_l10n.targetsDefault.toUpperCase()), findsWidgets);
      expect(find.text(_l10n.targetsCustom.toUpperCase()), findsNothing);
    });

    testWidgets('правка сохраняется как своя цель и читается обратно', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const TargetsScreen());
      final exercise = await _first(tester, c);

      await tester.tap(find.text(_name(exercise)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byTooltip(_l10n.settingsStepperIncrease(_l10n.targetsValue)),
      );
      await settle(tester);

      final profile = await _profile(tester, c);
      expect(profile.exerciseTargets, hasLength(1));
      final target = profile.exerciseTargets.single;
      expect(target.exerciseId, exercise.id);
      expect(target.min, 16);
      expect(target.max, 16);
      expect(target.lockedByUser, isTrue);
      // Экран показывает то, что сохранено.
      expect(find.text(_l10n.targetsCustom.toUpperCase()), findsOneWidget);
      expect(
        find.text(_l10n.targetsValueFixed(16, _l10n.targetsUnitReps)),
        findsOneWidget,
      );

      // Остальные упражнения остались на значении по умолчанию.
      final other = (await db(
        tester,
        () => c.read(contentProvider.future),
      )).exercises[1];
      expect(
        profile.exerciseTargets.where((t) => t.exerciseId == other.id),
        isEmpty,
      );
    });

    testWidgets('диапазон: «От» не выше «До», в БД min < max', (tester) async {
      final c = await pumpScreen(tester, const TargetsScreen());
      final exercise = await _first(tester, c);

      await tester.tap(find.text(_name(exercise)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_l10n.targetsRangeToggle.toUpperCase()));
      await settle(tester);

      final t = (await _profile(tester, c)).exerciseTargets.single;
      expect(t.min, 15);
      expect(t.max, greaterThan(15));
      expect(
        find.text(_l10n.targetsValueRange(t.min, t.max, _l10n.targetsUnitReps)),
        findsOneWidget,
      );
      // «От» нельзя поднять выше «До».
      final incFrom = find.byTooltip(
        _l10n.settingsStepperIncrease(_l10n.targetsFrom),
      );
      for (var i = 0; i < 8; i++) {
        await tester.tap(incFrom, warnIfMissed: false);
        await settle(tester);
      }
      final after = (await _profile(tester, c)).exerciseTargets.single;
      expect(after.min, lessThan(after.max));
      // Диапазон остался диапазоном: редактор не схлопнулся в «фикс».
      expect(incFrom, findsOneWidget);
      expect(
        find.text(
          _l10n.targetsValueRange(after.min, after.max, _l10n.targetsUnitReps),
        ),
        findsOneWidget,
      );
    });

    testWidgets('сброс возвращает к умолчанию и удаляет запись', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const TargetsScreen());
      final exercise = await _first(tester, c);
      await db(
        tester,
        () => c
            .read(profileRepositoryProvider)
            .upsertExerciseTarget(
              ExerciseTarget(
                exerciseId: exercise.id,
                min: 22,
                max: 22,
                lockedByUser: true,
              ),
            ),
      );
      await settle(tester);
      expect(
        find.text(_l10n.targetsValueFixed(22, _l10n.targetsUnitReps)),
        findsOneWidget,
      );

      await tester.tap(find.text(_name(exercise)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_l10n.targetsReset.toUpperCase()));
      await settle(tester);

      expect((await _profile(tester, c)).exerciseTargets, isEmpty);
      expect(find.text(_l10n.targetsCustom.toUpperCase()), findsNothing);
    });

    testWidgets('цель по умолчанию из настроек подхватывается в списке', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const TargetsScreen());
      await db(
        tester,
        () => c
            .read(profileRepositoryProvider)
            .setDefaultTargets(
              const DefaultTargets(
                reps: TargetRange(min: 8, max: 12),
                seconds: TargetRange(min: 30, max: 30),
              ),
            ),
      );
      await settle(tester);
      expect(
        find.text(_l10n.targetsValueRange(8, 12, _l10n.targetsUnitReps)),
        findsWidgets,
      );
    });

    testWidgets('320 px, textScale 1.5: без overflow, с раскрытым редактором', (
      tester,
    ) async {
      final c = await pumpScreen(
        tester,
        const TargetsScreen(),
        width: narrowLogicalWidth,
        textScale: bigTextScale,
      );
      final exercise = await _first(tester, c);
      await tester.tap(find.text(_name(exercise)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text(_l10n.targetsRangeToggle.toUpperCase()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(_l10n.targetsRangeToggle.toUpperCase()));
      await settle(tester);
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 12; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
