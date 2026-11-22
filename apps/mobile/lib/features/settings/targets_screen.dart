import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../data/content_loader.dart';
import '../../l10n/app_localizations.dart';
import 'settings_limits.dart';
import 'settings_providers.dart';
import 'widgets/number_stepper.dart';
import 'widgets/settings_page.dart';
import 'widgets/settings_panel.dart';
import 'widgets/switch_row.dart';

/// Экран «Цели упражнений»: у каждого упражнения своя цель (число + единица)
/// или значение по умолчанию из настроек. Правка пишется сразу
/// (`upsertExerciseTarget`, `lockedByUser: true` — прогрессия такую цель не
/// трогает), «сбросить» удаляет собственную цель.
///
/// Открывается через `Navigator.push` из настроек (маршрута в роутере нет).
class TargetsScreen extends ConsumerStatefulWidget {
  const TargetsScreen({super.key});

  @override
  ConsumerState<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends ConsumerState<TargetsScreen> {
  /// Упражнение, у которого раскрыт редактор.
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exercises = ref.watch(exercisesProvider);
    final profile = ref.watch(profileProvider);

    if (exercises.hasError || profile.hasError) {
      return SettingsPage(
        title: l10n.targetsTitle,
        children: [StatusMessage.error(l10n.targetsLoadError)],
      );
    }
    final list = exercises.value;
    final profileValue = profile.value;
    if (list == null || profileValue == null) {
      return SettingsPage(
        title: l10n.targetsTitle,
        children: [StatusMessage.loading(l10n.targetsLoading)],
      );
    }

    final language = Localizations.localeOf(context).languageCode;
    return SettingsPage(
      title: l10n.targetsTitle,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: TmbSpace.x4),
          child: Text(
            l10n.targetsHint,
            style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
          ),
        ),
        if (list.isEmpty)
          StatusMessage.info(l10n.targetsEmpty)
        else
          for (final exercise in list)
            _ExerciseTile(
              exercise: exercise,
              name: _nameOf(exercise, language),
              own: _ownTarget(profileValue, exercise.id),
              fallback: profileValue.defaultTargets.forUnit(exercise.unit),
              expanded: _expandedId == exercise.id,
              onToggleExpanded: () => setState(
                () => _expandedId = _expandedId == exercise.id
                    ? null
                    : exercise.id,
              ),
            ),
      ],
    );
  }

  static ExerciseTarget? _ownTarget(ProfileSettings profile, String id) {
    for (final t in profile.exerciseTargets) {
      if (t.exerciseId == id) return t;
    }
    return null;
  }

  /// Название по локали интерфейса, иначе `ru`, иначе первое имеющееся.
  static String _nameOf(Exercise e, String language) =>
      e.name[language] ?? e.name['ru'] ?? e.name.values.first;
}

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.name,
    required this.own,
    required this.fallback,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final Exercise exercise;
  final String name;
  final ExerciseTarget? own;
  final TargetRange fallback;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final writer = ref.read(settingsWriterProvider);
    final min = own?.min ?? fallback.min;
    final max = own?.max ?? fallback.max;
    final isReps = exercise.unit == ExerciseUnit.reps;
    final unit = isReps ? l10n.targetsUnitReps : l10n.targetsUnitSeconds;
    final step = isReps ? SettingsLimits.repsStep : SettingsLimits.secondsStep;
    final spread = isReps
        ? SettingsLimits.repsRangeSpread
        : SettingsLimits.secondsRangeSpread;
    final value = min == max
        ? l10n.targetsValueFixed(min, unit)
        : l10n.targetsValueRange(min, max, unit);
    final badge = own == null ? l10n.targetsDefault : l10n.targetsCustom;

    Future<void> save(int lo, int hi) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await writer.saveExerciseTarget(
          ExerciseTarget(
            exerciseId: exercise.id,
            min: lo,
            max: hi,
            lockedByUser: true,
          ),
        );
      } on Object {
        messenger.showSnackBar(SnackBar(content: Text(l10n.targetsSaveError)));
      }
    }

    Future<void> reset() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await writer.resetExerciseTarget(exercise.id);
      } on Object {
        messenger.showSnackBar(SnackBar(content: Text(l10n.targetsSaveError)));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: TmbSpace.x2),
      child: Container(
        decoration: BoxDecoration(
          color: TmbColor.surface,
          borderRadius: BorderRadius.circular(TmbRadius.sharp),
          border: Border.all(
            color: expanded ? TmbColor.borderAccent : TmbColor.borderSubtle,
            width: expanded ? TmbStroke.base : TmbStroke.thin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: expanded,
              label: '$name. $value. $badge',
              excludeSemantics: true,
              onTap: onToggleExpanded,
              child: InkWell(
                onTap: onToggleExpanded,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: TmbTheme.minTapTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(TmbSpace.x3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TmbType.bodyMd.copyWith(
                                  color: TmbColor.textPrimary,
                                ),
                              ),
                              const SizedBox(height: TmbSpace.x1),
                              // Бейдж и значение рядом, но с переносом: на
                              // узком экране с крупным шрифтом строка не
                              // должна вылезать за край.
                              Wrap(
                                spacing: TmbSpace.x3,
                                runSpacing: TmbSpace.x1,
                                children: [
                                  Text(
                                    badge.toUpperCase(),
                                    style: TmbType.labelSm.copyWith(
                                      color: own == null
                                          ? TmbColor.textSecondary
                                          : TmbColor.accent500,
                                    ),
                                  ),
                                  Text(
                                    value,
                                    style: TmbType.dataMono.copyWith(
                                      color: TmbColor.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: TmbSpace.x2),
                        Icon(
                          expanded ? Icons.expand_less : Icons.expand_more,
                          size: TmbSize.icon,
                          color: TmbColor.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  TmbSpace.x3,
                  0,
                  TmbSpace.x3,
                  TmbSpace.x3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (min == max)
                      NumberStepper(
                        label: l10n.targetsValue,
                        value: min,
                        min: SettingsLimits.targetMin,
                        max: SettingsLimits.targetMax,
                        step: step,
                        onChanged: (v) => save(v, v),
                      )
                    else ...[
                      NumberStepper(
                        label: l10n.targetsFrom,
                        value: min,
                        min: SettingsLimits.targetMin,
                        // Строго меньше «До»: равенство — фиксированная цель.
                        max: max - 1,
                        step: step,
                        onChanged: (v) => save(v, max),
                      ),
                      const SizedBox(height: TmbSpace.x3),
                      NumberStepper(
                        label: l10n.targetsTo,
                        value: max,
                        min: min + 1,
                        max: SettingsLimits.targetMax,
                        step: step,
                        onChanged: (v) => save(min, v),
                      ),
                    ],
                    const SizedBox(height: TmbSpace.x2),
                    SwitchRow(
                      label: l10n.targetsRangeToggle,
                      value: min != max,
                      onLabel: l10n.settingsOn,
                      offLabel: l10n.settingsOff,
                      onChanged: (range) {
                        if (range) {
                          final lo = min.clamp(
                            SettingsLimits.targetMin,
                            SettingsLimits.targetMax - spread,
                          );
                          save(lo, lo + spread);
                        } else {
                          save(min, min);
                        }
                      },
                    ),
                    const SizedBox(height: TmbSpace.x2),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: own == null ? null : reset,
                        child: Text(l10n.targetsReset.toUpperCase()),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
