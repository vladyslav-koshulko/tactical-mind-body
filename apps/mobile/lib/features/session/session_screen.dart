import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import 'cognitive_view.dart';
import 'session_controller.dart';
import 'session_format.dart';
import 'session_parts.dart';
import 'session_state.dart';

/// Маршрут `/session` — рабочий экран тренировки: от плана до итогов.
///
/// Экран только показывает [SessionState] и пробрасывает действия в
/// [SessionController]; по завершении сессии уходит на итоги заменой маршрута.
class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionControllerProvider, (previous, next) {
      final value = next.value;
      if (value is SessionEnded) {
        context.go(TmbRoutes.summaryOf(value.sessionId));
      }
    });
    final session = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);
    return session.when(
      loading: () => const _PreparingView(),
      error: (error, _) => _ErrorView(error: error),
      data: (state) => switch (state) {
        SessionRunning() => _RunningView(state: state, controller: controller),
        // Миг между записью итогов и переходом на экран итогов.
        SessionEnded() => const _PreparingView(),
      },
    );
  }
}

class _RunningView extends StatelessWidget {
  const _RunningView({required this.state, required this.controller});

  final SessionRunning state;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final engine = state.engine;
    final Widget view;
    if (state.awaitingFinish) {
      view = _FinalView(state: state, controller: controller);
    } else {
      view = switch (engine.phase) {
        Phase.physical => _PhysicalView(state: state, controller: controller),
        Phase.rest => _RestView(state: state, controller: controller),
        Phase.cognitive => CognitiveView(state: state, controller: controller),
        null => const _PreparingView(),
      };
    }
    // Системное «назад» — не выход, а то же подтверждение, что «Эвакуация».
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (state.awaitingFinish) {
          await controller.finish();
        } else if (await confirmEvacuation(context) && context.mounted) {
          await controller.evacuate();
        }
      },
      child: KeyedSubtree(
        key: ValueKey('block-${engine.blockIndex}-${state.awaitingFinish}'),
        child: view,
      ),
    );
  }
}

// --- подготовка и ошибка ---------------------------------------------------

class _PreparingView extends StatelessWidget {
  const _PreparingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: l10n.sessionLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: TmbSpace.x4),
              Text(
                l10n.sessionLoading.toUpperCase(),
                style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Пользователю — короткий текст, разработчику — причина в консоли (только
    // debug): без этого `_ => sessionErrorGeneric` скрывает любой сбой.
    assert(() {
      debugPrint('SessionScreen: не удалось начать операцию: $error');
      return true;
    }());
    final body = switch (error) {
      PlanningException(:final reason) => switch (reason) {
        PlanningFailure.noExercises => l10n.sessionErrorNoExercises,
        PlanningFailure.emptyTaskPool => l10n.sessionErrorEmptyTaskPool,
        PlanningFailure.emptyTemplate ||
        PlanningFailure.invalidBlock => l10n.sessionErrorGeneric,
      },
      _ => l10n.sessionErrorGeneric,
    };
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TmbSpace.x4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.sessionErrorTitle.toUpperCase(),
                  style: TmbType.displayLg.copyWith(color: TmbColor.warning),
                ),
              ),
              const SizedBox(height: TmbSpace.x3),
              Text(
                body,
                style: TmbType.bodyMd.copyWith(color: TmbColor.textPrimary),
              ),
              const SizedBox(height: TmbSpace.x6),
              TmbButton(
                label: l10n.sessionBackToDashboard,
                onPressed: () => context.go(TmbRoutes.home),
                phase: TmbPhase.physical,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- физическая фаза (экран 02) ---------------------------------------------

class _PhysicalView extends StatelessWidget {
  const _PhysicalView({required this.state, required this.controller});

  final SessionRunning state;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final engine = state.engine;
    final block = engine.block! as PlannedPhysicalBlock;
    final current = engine.exercise!;
    final index = engine.exerciseIndex!;
    final bySeconds = current.unit == ExerciseUnit.seconds;

    final String timeText;
    final String semantic;
    final double progress;
    if (bySeconds) {
      final remaining = engine.stageRemainingMs ?? 0;
      timeText = formatMmSs(remaining);
      semantic = l10n.sessionTimerRemaining(timeText);
      progress = (remaining / (current.prescribed * 1000)).clamp(0.0, 1.0);
    } else {
      // Повторения срока не имеют: цифры — время круга, дуга — сколько
      // упражнений круга осталось.
      timeText = formatMmSs(engine.blockElapsedMs ?? 0);
      semantic = l10n.sessionTimerElapsed(timeText);
      progress = (block.exercises.length - index) / block.exercises.length;
    }

    final items = [
      for (var i = 0; i < block.exercises.length; i++)
        TmbExerciseItem(
          name: exerciseName(block.exercises[i].exercise, locale),
          targetValue: block.exercises[i].prescribed,
          targetUnit: _unitLabel(l10n, block.exercises[i].unit),
          status: i < index
              ? TmbExerciseStatus.done
              : i == index
              ? TmbExerciseStatus.current
              : TmbExerciseStatus.upcoming,
          statusLabel: i < index
              ? l10n.sessionExerciseDone
              : i == index
              ? l10n.sessionExerciseCurrent
              : l10n.sessionExerciseUpcoming,
        ),
    ];

    return TmbPhaseScaffold(
      phase: TmbPhase.physical,
      phaseLabel: l10n.phasePhysical,
      title: l10n.sessionRoundTitle(
        block.roundIndex + 1,
        state.plan.template.physicalBlockCount,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.outcome != null) ...[
              OutcomeBanner(outcome: state.outcome!),
              const SizedBox(height: TmbSpace.x4),
            ],
            if (state.ratingOpen) ...[
              RoundRatingCard(rating: state.rating, onRate: controller.rate),
              const SizedBox(height: TmbSpace.x4),
            ],
            TmbRadarTimer(
              timeText: timeText,
              progress: progress,
              phaseLabel: l10n.phasePhysical,
              semanticLabel: semantic,
            ),
            const SizedBox(height: TmbSpace.x4),
            TmbRoundList(items: items),
          ],
        ),
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TmbButton(
            label: l10n.sessionSetDone,
            onPressed: controller.completeSet,
            expand: true,
          ),
          const SizedBox(height: TmbSpace.x2),
          Row(
            children: [
              Expanded(
                child: TmbButton(
                  label: l10n.sessionSetCustom,
                  variant: TmbButtonVariant.secondary,
                  expand: true,
                  onPressed: () async {
                    final done = await showActualDoneSheet(
                      context,
                      initial: current.prescribed,
                      unitLabel: _unitLabel(l10n, current.unit),
                    );
                    if (done != null) controller.completeSet(done);
                  },
                ),
              ),
              const SizedBox(width: TmbSpace.x2),
              Expanded(
                child: TmbButton(
                  label: l10n.sessionSkipExercise,
                  variant: TmbButtonVariant.secondary,
                  expand: true,
                  onPressed: controller.skipExercise,
                ),
              ),
            ],
          ),
          const SizedBox(height: TmbSpace.x2),
          EvacuateButton(controller: controller),
        ],
      ),
    );
  }
}

String _unitLabel(AppLocalizations l10n, ExerciseUnit unit) => switch (unit) {
  ExerciseUnit.reps => l10n.sessionUnitReps,
  ExerciseUnit.seconds => l10n.sessionUnitSeconds,
};

// --- пассивный отдых -----------------------------------------------------------

class _RestView extends StatelessWidget {
  const _RestView({required this.state, required this.controller});

  final SessionRunning state;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engine = state.engine;
    final block = engine.block! as PlannedRestBlock;
    final remaining = engine.blockRemainingMs ?? 0;
    final timeText = formatMmSs(remaining);

    // У отдыха нет своего значения `TmbPhase`: цвет — физический (тело ещё
    // в режиме нагрузки), а отличие несёт подпись «Отдых» (текстовый канал).
    return TmbPhaseScaffold(
      phase: TmbPhase.physical,
      phaseLabel: l10n.sessionRestPhase,
      title: l10n.sessionRestTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.ratingOpen) ...[
              RoundRatingCard(rating: state.rating, onRate: controller.rate),
              const SizedBox(height: TmbSpace.x4),
            ],
            TmbRadarTimer(
              timeText: timeText,
              progress: (remaining / (block.durationSec * 1000)).clamp(
                0.0,
                1.0,
              ),
              phaseLabel: l10n.sessionRestPhase,
              semanticLabel: l10n.sessionTimerRemaining(timeText),
            ),
          ],
        ),
      ),
      bottom: EvacuateButton(controller: controller),
    );
  }
}

// --- конец сессии: оценка последнего круга ---------------------------------------

class _FinalView extends StatelessWidget {
  const _FinalView({required this.state, required this.controller});

  final SessionRunning state;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TmbPhaseScaffold(
      phase: TmbPhase.physical,
      phaseLabel: l10n.sessionFinishedTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.outcome != null) ...[
              OutcomeBanner(outcome: state.outcome!),
              const SizedBox(height: TmbSpace.x4),
            ],
            RoundRatingCard(rating: state.rating, onRate: controller.rate),
          ],
        ),
      ),
      bottom: TmbButton(
        label: l10n.sessionToSummary,
        onPressed: controller.finish,
        expand: true,
      ),
    );
  }
}
