import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import 'about_screen.dart';
import 'export_screen.dart';
import 'settings_limits.dart';
import 'settings_providers.dart';
import 'targets_screen.dart';
import 'widgets/link_row.dart';
import 'widgets/number_stepper.dart';
import 'widgets/selectable_tile.dart';
import 'widgets/settings_page.dart';
import 'widgets/settings_panel.dart';
import 'widgets/switch_row.dart';

/// Маршрут `/settings` — настройки. Каждое изменение сразу пишется в БД через
/// [SettingsWriter]; экран читает потоки профиля и параметров сессии, поэтому
/// показывает то, что реально сохранено.
///
/// Вложенные экраны «Цели упражнений», «Экспорт», «О приложении» открываются
/// обычным `Navigator.push`: именованных маршрутов для них в роутере нет.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(sessionPreferencesProvider);
    final profile = ref.watch(profileProvider);

    if (prefs.hasError || profile.hasError) {
      return SettingsPage(
        title: l10n.settingsTitle,
        children: [StatusMessage.error(l10n.settingsLoadError)],
      );
    }
    final prefsValue = prefs.value;
    final profileValue = profile.value;
    if (prefsValue == null || profileValue == null) {
      return SettingsPage(
        title: l10n.settingsTitle,
        children: [StatusMessage.loading(l10n.settingsLoading)],
      );
    }

    return SettingsPage(
      title: l10n.settingsTitle,
      children: [
        _SessionPanel(prefs: prefsValue),
        _ParamsPanel(prefs: prefsValue),
        _RepsPanel(targets: profileValue.defaultTargets),
        _ProgressionPanel(enabled: profileValue.progression.enabled),
        _MorePanel(profile: profileValue),
      ],
    );
  }
}

/// Запись с показом ошибки, если она не удалась (тихо терять нельзя).
Future<void> _save(
  BuildContext context,
  String errorText,
  Future<void> Function() job,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await job();
  } on Object {
    messenger.showSnackBar(SnackBar(content: Text(errorText)));
  }
}

class _SessionPanel extends ConsumerWidget {
  const _SessionPanel({required this.prefs});

  final SessionPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final writer = ref.read(settingsWriterProvider);

    final options = <(SessionTemplateKind, String, String)>[
      (
        SessionTemplateKind.dualTask,
        l10n.settingsTemplateDualTask,
        l10n.settingsTemplateDualTaskHint,
      ),
      (
        SessionTemplateKind.physicalOnly,
        l10n.settingsTemplatePhysicalOnly,
        l10n.settingsTemplatePhysicalOnlyHint,
      ),
      (
        SessionTemplateKind.cognitiveOnly,
        l10n.settingsTemplateCognitiveOnly,
        l10n.settingsTemplateCognitiveOnlyHint,
      ),
    ];

    return SettingsPanel(
      heading: l10n.settingsSectionSession,
      children: [
        for (final (kind, label, hint) in options) ...[
          SelectableTile(
            label: label,
            hint: hint,
            selected: prefs.template == kind,
            onTap: () => _save(
              context,
              l10n.settingsSaveError,
              () => writer.updatePreferences((p) => p.copyWith(template: kind)),
            ),
          ),
          if (kind != options.last.$1) const SizedBox(height: TmbSpace.x2),
        ],
      ],
    );
  }
}

class _ParamsPanel extends ConsumerWidget {
  const _ParamsPanel({required this.prefs});

  final SessionPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final writer = ref.read(settingsWriterProvider);
    String seconds(int v) => l10n.settingsSecondsValue(v);

    Future<void> save(SessionPreferences Function(SessionPreferences) f) =>
        _save(
          context,
          l10n.settingsSaveError,
          () => writer.updatePreferences(f),
        );

    final template = prefs.template;
    return SettingsPanel(
      heading: l10n.settingsSectionParams,
      children: [
        NumberStepper(
          label: template == SessionTemplateKind.cognitiveOnly
              ? l10n.settingsWindows
              : l10n.settingsRounds,
          value: prefs.rounds,
          min: SettingsLimits.roundsMin,
          max: SettingsLimits.roundsMax,
          onChanged: (v) => save((p) => p.copyWith(rounds: v)),
        ),
        if (template != SessionTemplateKind.physicalOnly) ...[
          const SizedBox(height: TmbSpace.x4),
          NumberStepper(
            label: l10n.settingsCognitiveSec,
            value: prefs.cognitiveSec,
            min: SettingsLimits.cognitiveSecMin,
            max: SettingsLimits.cognitiveSecMax,
            step: SettingsLimits.cognitiveSecStep,
            format: seconds,
            onChanged: (v) => save((p) => p.copyWith(cognitiveSec: v)),
          ),
        ],
        if (template == SessionTemplateKind.physicalOnly) ...[
          const SizedBox(height: TmbSpace.x4),
          NumberStepper(
            label: l10n.settingsRestSec,
            value: prefs.restSec,
            min: SettingsLimits.restSecMin,
            max: SettingsLimits.restSecMax,
            step: SettingsLimits.restSecStep,
            format: (v) => v == 0 ? l10n.settingsRestNone : seconds(v),
            onChanged: (v) => save((p) => p.copyWith(restSec: v)),
          ),
        ],
      ],
    );
  }
}

class _RepsPanel extends ConsumerWidget {
  const _RepsPanel({required this.targets});

  final DefaultTargets targets;

  bool get _isFixed => targets.reps.isFixed && targets.seconds.isFixed;

  static TargetRange _fixed(TargetRange r) =>
      TargetRange(min: r.min, max: r.min);

  static TargetRange _widen(TargetRange r, int spread) {
    final lo = r.min.clamp(
      SettingsLimits.targetMin,
      SettingsLimits.targetMax - spread,
    );
    return TargetRange(min: lo, max: lo + spread);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final writer = ref.read(settingsWriterProvider);

    Future<void> save(DefaultTargets Function(DefaultTargets) f) => _save(
      context,
      l10n.settingsSaveError,
      () => writer.updateDefaultTargets(f),
    );

    return SettingsPanel(
      heading: l10n.settingsSectionReps,
      hint: l10n.settingsRepsHint,
      children: [
        Text(
          l10n.settingsRepsMode.toUpperCase(),
          style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
        ),
        const SizedBox(height: TmbSpace.x2),
        Wrap(
          spacing: TmbSpace.x2,
          runSpacing: TmbSpace.x2,
          children: [
            SelectableTile(
              label: l10n.settingsRepsModeFixed,
              selected: _isFixed,
              onTap: () => save(
                (t) => DefaultTargets(
                  reps: _fixed(t.reps),
                  seconds: _fixed(t.seconds),
                ),
              ),
            ),
            SelectableTile(
              label: l10n.settingsRepsModeRange,
              selected: !_isFixed,
              onTap: () => save(
                (t) => DefaultTargets(
                  reps: t.reps.isFixed
                      ? _widen(t.reps, SettingsLimits.repsRangeSpread)
                      : t.reps,
                  seconds: t.seconds.isFixed
                      ? _widen(t.seconds, SettingsLimits.secondsRangeSpread)
                      : t.seconds,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TmbSpace.x4),
        _UnitTargetEditor(
          heading: l10n.settingsTargetReps,
          range: targets.reps,
          fixed: _isFixed,
          step: SettingsLimits.repsStep,
          onChanged: (r) =>
              save((t) => DefaultTargets(reps: r, seconds: t.seconds)),
        ),
        const SizedBox(height: TmbSpace.x4),
        _UnitTargetEditor(
          heading: l10n.settingsTargetSeconds,
          range: targets.seconds,
          fixed: _isFixed,
          step: SettingsLimits.secondsStep,
          onChanged: (r) =>
              save((t) => DefaultTargets(reps: t.reps, seconds: r)),
        ),
      ],
    );
  }
}

/// Цель одной единицы: одно число (фикс) или пара «от/до».
class _UnitTargetEditor extends StatelessWidget {
  const _UnitTargetEditor({
    required this.heading,
    required this.range,
    required this.fixed,
    required this.step,
    required this.onChanged,
  });

  final String heading;
  final TargetRange range;
  final bool fixed;
  final int step;
  final ValueChanged<TargetRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (fixed) {
      return NumberStepper(
        label: heading,
        value: range.min,
        min: SettingsLimits.targetMin,
        max: SettingsLimits.targetMax,
        step: step,
        onChanged: (v) => onChanged(TargetRange(min: v, max: v)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading.toUpperCase(),
          style: TmbType.labelMd.copyWith(color: TmbColor.textPrimary),
        ),
        const SizedBox(height: TmbSpace.x2),
        NumberStepper(
          label: '$heading · ${l10n.settingsTargetFrom}',
          value: range.min,
          min: SettingsLimits.targetMin,
          // Строго меньше «До»: равенство — это уже фиксированная цель, и
          // редактор диапазона сам бы схлопнулся посреди нажатий.
          max: range.isFixed ? range.max : range.max - 1,
          step: step,
          onChanged: (v) => onChanged(TargetRange(min: v, max: range.max)),
        ),
        const SizedBox(height: TmbSpace.x3),
        NumberStepper(
          label: '$heading · ${l10n.settingsTargetTo}',
          value: range.max,
          min: range.isFixed ? range.min : range.min + 1,
          max: SettingsLimits.targetMax,
          step: step,
          onChanged: (v) => onChanged(TargetRange(min: range.min, max: v)),
        ),
      ],
    );
  }
}

class _ProgressionPanel extends ConsumerWidget {
  const _ProgressionPanel({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SettingsPanel(
      heading: l10n.settingsSectionProgression,
      hint: l10n.settingsProgressionHint,
      children: [
        SwitchRow(
          label: l10n.settingsProgressionToggle,
          value: enabled,
          onLabel: l10n.settingsOn,
          offLabel: l10n.settingsOff,
          onChanged: (v) => _save(
            context,
            l10n.settingsSaveError,
            () => ref
                .read(settingsWriterProvider)
                .setProgressionEnabled(enabled: v),
          ),
        ),
      ],
    );
  }
}

class _MorePanel extends ConsumerWidget {
  const _MorePanel({required this.profile});

  final ProfileSettings profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(categoryCatalogProvider).value;
    final categories = catalog?.summary(
      catalog.allDomains,
      profile.disabledCategories,
    );

    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    return SettingsPanel(
      heading: l10n.settingsSectionMore,
      children: [
        LinkRow(
          title: l10n.settingsLinkCategories,
          summary: categories == null
              ? null
              : l10n.settingsLinkCategoriesSummary(
                  categories.enabled,
                  categories.total,
                ),
          onTap: () => context.push(TmbRoutes.categories),
        ),
        LinkRow(
          title: l10n.settingsLinkTargets,
          summary: l10n.settingsLinkTargetsSummary(
            profile.exerciseTargets.length,
          ),
          onTap: () => open(const TargetsScreen()),
        ),
        LinkRow(
          title: l10n.settingsLinkExport,
          onTap: () => open(const ExportScreen()),
        ),
        LinkRow(
          title: l10n.settingsLinkAbout,
          onTap: () => open(const AboutScreen()),
        ),
      ],
    );
  }
}
