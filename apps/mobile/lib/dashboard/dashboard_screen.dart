import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../app/router.dart';
import '../features/settings/settings_providers.dart';
import '../features/settings/widgets/selectable_tile.dart';
import '../l10n/app_localizations.dart';
import 'labels.dart';
import 'last_operation.dart';
import 'location_tile.dart';

/// Локации, с которыми v0.1 умеет работать. Встроенный пак упражнений — только
/// «Дом» (`locations: [HOME]`); остальные показаны как «скоро», а не
/// притворяются рабочими.
const availableLocations = {Location.home};

/// Экран №01 «Тактический дашборд»: локация и сложность читаются из
/// `SessionPreferences` и пишутся в них же сразу при выборе; блок «последняя
/// операция» — по последней сессии из БД.
///
/// Рекламы здесь пока нет (инвариант 10 разрешает баннер только тут и в архиве).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Если в БД осталась недоступная локация, сессия не соберётся (нет
    // упражнений): приводим сохранённый выбор к рабочему.
    ref.listenManual(sessionPreferencesProvider, (_, next) {
      final prefs = next.value;
      if (prefs != null && !availableLocations.contains(prefs.location)) {
        unawaited(
          ref
              .read(settingsWriterProvider)
              .updatePreferences((p) => p.copyWith(location: Location.home))
              .then<void>((_) {}, onError: (_) {}),
        );
      }
    }, fireImmediately: true);
  }

  Future<void> _save(
    SessionPreferences Function(SessionPreferences) change,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = AppLocalizations.of(context).dashboardSaveError;
    try {
      await ref.read(settingsWriterProvider).updatePreferences(change);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Пока параметры читаются (или не прочитались), показываем значения по
    // умолчанию — экран не пустой.
    final prefs =
        ref.watch(sessionPreferencesProvider).value ??
        SessionPreferences.standard;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TmbSpace.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.appName.toUpperCase(),
                            style: TmbType.labelMd.copyWith(
                              color: TmbColor.textSecondary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.dashboardSettings,
                          // Цель касания 48 (DESIGN.md, правило 4): по умолчанию
                          // InkWell у IconButton — 40.
                          constraints: const BoxConstraints(
                            minWidth: TmbTheme.minTapTarget,
                            minHeight: TmbTheme.minTapTarget,
                          ),
                          icon: const Icon(Icons.settings),
                          onPressed: () => context.push(TmbRoutes.settings),
                        ),
                      ],
                    ),
                    const SizedBox(height: TmbSpace.x2),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.dashboardTitle.toUpperCase(),
                        style: TmbType.displayHero.copyWith(
                          color: TmbColor.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: TmbSpace.x6),
                    _Heading(l10n.dashboardLocationHeading),
                    const SizedBox(height: TmbSpace.x2),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, location)
                              in Location.values.indexed) ...[
                            if (i > 0) const SizedBox(width: TmbSpace.x2),
                            Expanded(
                              child: LocationTile(
                                index: '0${i + 1}',
                                name: locationLabel(l10n, location),
                                selectedLabel: l10n.locationSelected,
                                selected:
                                    prefs.location == location &&
                                    availableLocations.contains(location),
                                soonLabel: availableLocations.contains(location)
                                    ? null
                                    : l10n.dashboardLocationSoon,
                                onTap: () => _save(
                                  (p) => p.copyWith(location: location),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: TmbSpace.x6),
                    _Heading(l10n.dashboardDifficultyHeading),
                    const SizedBox(height: TmbSpace.x2),
                    Wrap(
                      spacing: TmbSpace.x2,
                      runSpacing: TmbSpace.x2,
                      children: [
                        for (final level in DifficultyLevel.values)
                          SelectableTile(
                            label: difficultyLabel(l10n, level),
                            selected: prefs.difficulty == level,
                            onTap: () =>
                                _save((p) => p.copyWith(difficulty: level)),
                          ),
                      ],
                    ),
                    const SizedBox(height: TmbSpace.x6),
                    const _LastOperationPanel(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TmbSpace.x4),
              child: SizedBox(
                width: double.infinity,
                // Единственная Primary-кнопка экрана (DESIGN.md, правило 1).
                child: FilledButton(
                  onPressed: () => context.push(TmbRoutes.session),
                  child: Text(l10n.startOperation.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
      ),
    );
  }
}

class _LastOperationPanel extends ConsumerWidget {
  const _LastOperationPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final last = ref.watch(lastOperationProvider).value;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lastOperationTitle.toUpperCase(),
          style: TmbType.labelLg.copyWith(color: TmbColor.textPrimary),
        ),
        const SizedBox(height: TmbSpace.x3),
        if (last == null)
          Text(
            l10n.lastOperationEmpty,
            style: TmbType.bodyMd.copyWith(color: TmbColor.textSecondary),
          )
        else
          _LastOperationDetails(last: last),
        const SizedBox(height: TmbSpace.x4),
        // Легенда фаз: цвет + форма + текст (инвариант 6).
        Wrap(
          spacing: TmbSpace.x4,
          runSpacing: TmbSpace.x2,
          children: [
            TmbPhaseBadge(phase: TmbPhase.physical, label: l10n.phasePhysical),
            TmbPhaseBadge(
              phase: TmbPhase.cognitive,
              label: l10n.phaseCognitive,
            ),
          ],
        ),
      ],
    );

    return Material(
      color: TmbColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TmbRadius.sharp),
        side: const BorderSide(color: TmbColor.borderSubtle),
      ),
      child: last == null
          ? Padding(padding: const EdgeInsets.all(TmbSpace.x4), child: body)
          : InkWell(
              // Итог сессии — уже существующий маршрут (deep link из архива).
              onTap: () => context.push(TmbRoutes.summaryOf(last.session.id)),
              child: Padding(
                padding: const EdgeInsets.all(TmbSpace.x4),
                child: body,
              ),
            ),
    );
  }
}

class _LastOperationDetails extends StatelessWidget {
  const _LastOperationDetails({required this.last});

  final LastOperation last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = last.session;
    // Время показываем в поясе сессии, а не устройства.
    final local = DateTime.fromMillisecondsSinceEpoch(
      session.startedAt,
      isUtc: true,
    ).add(Duration(minutes: session.utcOffsetMin));
    final when = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_Hm()
        .format(local);
    final secondary = TmbType.bodyMd.copyWith(color: TmbColor.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          when,
          style: TmbType.dataMono.copyWith(color: TmbColor.textPrimary),
        ),
        const SizedBox(height: TmbSpace.x2),
        Text(
          '${templateLabel(l10n, session.template)} · '
          '${difficultyLabel(l10n, session.difficulty)} · '
          '${locationLabel(l10n, session.location)}',
          style: secondary,
        ),
        const SizedBox(height: TmbSpace.x2),
        // Статус — значок и текст, не только цвет.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: TmbSpace.x1,
          children: [
            Icon(
              last.isFinished
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              size: TmbSize.icon,
              color: last.isFinished
                  ? TmbColor.accent500
                  : TmbColor.textSecondary,
            ),
            Text(
              (last.isFinished
                      ? l10n.dashboardLastOperationDone
                      : l10n.dashboardLastOperationInterrupted)
                  .toUpperCase(),
              style: TmbType.labelMd.copyWith(color: TmbColor.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: TmbSpace.x2),
        Text(
          '${l10n.dashboardLastOperationRounds(last.roundCount)} · '
          '${l10n.dashboardLastOperationTasks(last.taskCount)}',
          style: secondary,
        ),
        const SizedBox(height: TmbSpace.x2),
        Text(
          l10n.dashboardLastOperationDetails.toUpperCase(),
          style: TmbType.labelSm.copyWith(color: TmbColor.accent500),
        ),
      ],
    );
  }
}
