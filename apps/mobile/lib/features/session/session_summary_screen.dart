import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../app/router.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'session_format.dart';
import 'session_stats.dart';

/// Сессия со всеми событиями из БД; `null` — такой сессии нет.
final sessionBundleProvider = FutureProvider.autoDispose
    .family<SessionBundle?, String>(
      (ref, sessionId) =>
          ref.watch(sessionRepositoryProvider).loadSession(sessionId),
    );

/// Маршрут `/session/summary/:sessionId` — итог сессии. Только отображение
/// записанных событий: клиент ничего не считает в зачёт и ничего не
/// отправляет (инвариант 8).
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bundle = ref.watch(sessionBundleProvider(sessionId));
    return Scaffold(
      body: SafeArea(
        child: bundle.when(
          loading: () => Center(
            child: Semantics(
              label: l10n.sessionLoading,
              child: const CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _Message(
            title: l10n.sessionSummaryTitle,
            text: l10n.sessionSummaryLoadError,
          ),
          data: (bundle) => bundle == null
              ? _Message(
                  title: l10n.sessionSummaryTitle,
                  text: l10n.sessionSummaryNotFound(sessionId),
                )
              : _Summary(stats: SessionStats.of(bundle)),
        ),
      ),
    );
  }
}

/// Сообщение вместо итогов (нет сессии, ошибка чтения) и выход на дашборд.
class _Message extends StatelessWidget {
  const _Message({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(TmbSpace.x4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: TmbType.displayLg.copyWith(color: TmbColor.textPrimary),
            ),
          ),
          const SizedBox(height: TmbSpace.x3),
          Text(
            text,
            style: TmbType.bodyMd.copyWith(color: TmbColor.textSecondary),
          ),
          const SizedBox(height: TmbSpace.x6),
          TmbButton(
            label: l10n.sessionSummaryToDashboard,
            onPressed: () => context.go(TmbRoutes.home),
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.stats});

  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final none = l10n.sessionSummaryNone;

    String seconds(int? ms) => ms == null
        ? none
        : l10n.sessionSummarySecondsValue((ms / 1000).toStringAsFixed(1));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TmbSpace.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.sessionSummaryTitle.toUpperCase(),
                    style: TmbType.displayLg.copyWith(
                      color: TmbColor.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: TmbSpace.x2),
                _StatusLine(completed: stats.completed),
                const SizedBox(height: TmbSpace.x4),
                _Section(
                  title: l10n.sessionSummaryGeneral,
                  rows: [
                    (l10n.sessionSummaryDuration, formatMmSs(stats.durationMs)),
                    (
                      l10n.sessionSummaryRounds,
                      stats.hasPhysical ? '${stats.rounds}' : none,
                    ),
                  ],
                ),
                const SizedBox(height: TmbSpace.x3),
                _Section(
                  title: l10n.sessionSummaryPhysical,
                  rows: stats.hasPhysical
                      ? [
                          (
                            l10n.sessionSummarySets,
                            l10n.sessionSummaryOutOf(
                              stats.setsDone,
                              stats.setsTotal,
                            ),
                          ),
                          if (stats.repsPlanned > 0)
                            (
                              l10n.sessionSummaryReps,
                              l10n.sessionSummaryFactPlan(
                                stats.repsDone,
                                stats.repsPlanned,
                              ),
                            ),
                          if (stats.secondsPlanned > 0)
                            (
                              l10n.sessionSummarySeconds,
                              l10n.sessionSummaryFactPlan(
                                stats.secondsDone,
                                stats.secondsPlanned,
                              ),
                            ),
                        ]
                      : [(l10n.sessionSummarySets, none)],
                ),
                const SizedBox(height: TmbSpace.x3),
                _Section(
                  title: l10n.sessionSummaryTasks,
                  rows: stats.attempts == 0
                      ? [(l10n.sessionSummaryNoTasks, none)]
                      : [
                          (l10n.sessionSummaryCorrect, '${stats.correct}'),
                          (l10n.sessionSummaryWrong, '${stats.wrong}'),
                          (l10n.sessionSummaryTimeout, '${stats.timeouts}'),
                          (l10n.sessionSummarySkipped, '${stats.skipped}'),
                          (
                            l10n.sessionSummaryLatency,
                            seconds(stats.averageLatencyMs),
                          ),
                        ],
                ),
                if (stats.verbalTotal > 0) ...[
                  const SizedBox(height: TmbSpace.x3),
                  _Section(
                    title: l10n.sessionSummaryVerbal,
                    rows: [
                      (
                        l10n.sessionSummaryVerbalDone,
                        l10n.sessionSummaryOutOf(
                          stats.verbalAnswered,
                          stats.verbalTotal,
                        ),
                      ),
                      (
                        l10n.sessionSummaryVerbalRating,
                        stats.verbalAverageRating == null
                            ? none
                            : l10n.sessionSummaryRatingValue(
                                stats.verbalAverageRating!.toStringAsFixed(1),
                              ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TmbSpace.x4,
            0,
            TmbSpace.x4,
            TmbSpace.x4,
          ),
          child: TmbButton(
            label: l10n.sessionSummaryToDashboard,
            onPressed: () => context.go(TmbRoutes.home),
            expand: true,
          ),
        ),
      ],
    );
  }
}

/// «Завершена» / «Прервана»: иконка и слово, не цвет.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle_outline : Icons.warning_amber,
          size: TmbSize.icon,
          color: TmbColor.textSecondary,
        ),
        const SizedBox(width: TmbSpace.x2),
        Expanded(
          child: Text(
            (completed
                    ? l10n.sessionSummaryStatusCompleted
                    : l10n.sessionSummaryStatusAborted)
                .toUpperCase(),
            style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TmbColor.raised,
        borderRadius: const BorderRadius.all(Radius.circular(TmbRadius.sharp)),
        border: Border.all(
          color: TmbColor.borderDefault,
          width: TmbStroke.base,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TmbSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
              ),
            ),
            for (final (label, value) in rows) ...[
              const SizedBox(height: TmbSpace.x2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TmbType.bodyMd.copyWith(
                        color: TmbColor.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: TmbSpace.x3),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        style: TmbType.dataMetric.copyWith(
                          color: TmbColor.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
