import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../l10n/app_localizations.dart';
import 'session_controller.dart';
import 'session_parts.dart';
import 'session_state.dart';
import 'task_views.dart';

/// Когнитивная пауза (экран 03): весь экран в оранжевом, вид ответа зависит
/// от архетипа текущей задачи. Фаза читается и без цвета: ромб и подпись в
/// шапке `TmbPhaseScaffold`.
class CognitiveView extends StatelessWidget {
  const CognitiveView({
    required this.state,
    required this.controller,
    super.key,
  });

  final SessionRunning state;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engine = state.engine;
    final block = engine.block! as PlannedCognitiveBlock;
    final planned = engine.task!;
    final stage = engine.stage!;

    // Состояние ответа сбрасывается на каждой новой задаче и стадии; verbal
    // держит своё состояние на обеих стадиях (речь → самопроверка).
    final stageKey = planned.task is VerbalTask
        ? '${engine.blockIndex}/${engine.taskIndex}'
        : '${engine.blockIndex}/${engine.taskIndex}/${stage.name}';

    final totalMs = switch (stage) {
      TaskStage.study => planned.studySec * 1000,
      TaskStage.answer => planned.task.timeSec * 1000,
      TaskStage.selfCheck => block.durationSec * 1000,
    };

    return TmbPhaseScaffold(
      phase: TmbPhase.cognitive,
      phaseLabel: l10n.phaseCognitive,
      title: l10n.sessionTaskTitle(engine.taskIndex! + 1, block.tasks.length),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.outcome != null) ...[
              OutcomeBanner(outcome: state.outcome!),
              const SizedBox(height: TmbSpace.x4),
            ],
            TaskTimeBar(
              remainingMs: engine.stageRemainingMs ?? 0,
              totalMs: totalMs,
            ),
            const SizedBox(height: TmbSpace.x4),
            KeyedSubtree(
              key: ValueKey(stageKey),
              child: _TaskBody(
                planned: planned,
                stage: stage,
                dueCues: engine.dueCues,
                controller: controller,
              ),
            ),
            const SizedBox(height: TmbSpace.x6),
            TmbButton(
              label: l10n.sessionTaskSkip,
              variant: TmbButtonVariant.secondary,
              expand: true,
              onPressed: controller.skipTask,
            ),
          ],
        ),
      ),
      // «Эвакуация» закреплена вне прокрутки: цифровая клавиатура, длинный
      // текст задачи или крупный шрифт не должны уводить её за экран.
      bottom: EvacuateButton(controller: controller),
    );
  }
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({
    required this.planned,
    required this.stage,
    required this.dueCues,
    required this.controller,
  });

  final PlannedTask planned;
  final TaskStage stage;
  final List<DueCue> dueCues;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final task = planned.task;
    final answer = controller.submitAnswer;

    Widget withPrompt(Widget input, {String? text, String? label}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaskTextCard(text: text ?? task.prompt, label: label),
        const SizedBox(height: TmbSpace.x4),
        input,
      ],
    );

    switch (task) {
      case RecallTask():
        return withPrompt(
          RecallAnswerView(
            expected: task.answer,
            onSubmit: (text) => answer(TaskAnswer.recall(text)),
          ),
        );
      case DelayedRecallTask():
        if (stage == TaskStage.study) {
          return StudyTextView(
            prompt: task.prompt,
            text: task.memorize,
            onDone: controller.endStudy,
          );
        }
        return withPrompt(
          RecallAnswerView(
            expected: task.answer,
            onSubmit: (text) => answer(TaskAnswer.recall(text)),
          ),
          text: task.question,
          label: l10n.sessionRecallQuestionHint,
        );
      case ChoiceTask():
        return withPrompt(
          ChoiceAnswerView(task: task, seed: planned.seed, onSubmit: answer),
        );
      case OrderingTask():
        return withPrompt(
          OrderingAnswerView(task: task, seed: planned.seed, onSubmit: answer),
        );
      case SpatialTask():
        if (stage == TaskStage.study) {
          return SpatialStudyView(task: task, onDone: controller.endStudy);
        }
        return withPrompt(SpatialAnswerView(task: task, onSubmit: answer));
      case VerbalTask():
        return withPrompt(
          VerbalView(
            task: task,
            cues: dueCues,
            selfCheckStage: stage == TaskStage.selfCheck,
            onSubmit: answer,
          ),
        );
      case StreamTask():
        // В план не попадает до v0.2 (SCHEMAS §9, решение 33); страховка на
        // случай чужого плана — не оставить пользователя в тупике.
        return TaskTextCard(text: l10n.sessionTaskUnsupported);
    }
  }
}
