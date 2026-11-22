import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../l10n/app_localizations.dart';
import 'session_controller.dart';
import 'session_format.dart';

/// Подпись оценки круга из ARB.
String effortLabel(AppLocalizations l10n, TmbEffort effort) => switch (effort) {
  TmbEffort.hard => l10n.sessionEffortHard,
  TmbEffort.normal => l10n.sessionEffortNormal,
  TmbEffort.easy => l10n.sessionEffortEasy,
};

/// Оценка прошлого круга одним нажатием. После выбора сворачивается в одну
/// строку: на экране тренировки каждый пиксель на счету.
class RoundRatingCard extends StatelessWidget {
  const RoundRatingCard({
    required this.rating,
    required this.onRate,
    super.key,
  });

  final TmbEffort? rating;
  final ValueChanged<TmbEffort> onRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chosen = rating;
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
        padding: const EdgeInsets.all(TmbSpace.x3),
        child: chosen != null
            ? Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: TmbSize.icon,
                    color: TmbColor.textSecondary,
                  ),
                  const SizedBox(width: TmbSpace.x2),
                  Expanded(
                    child: Text(
                      l10n.sessionRatingSaved(effortLabel(l10n, chosen)),
                      style: TmbType.dataMono.copyWith(
                        color: TmbColor.textSecondary,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.sessionRatingTitle.toUpperCase(),
                    style: TmbType.labelMd.copyWith(
                      color: TmbColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: TmbSpace.x2),
                  TmbEffortPicker(
                    value: null,
                    onChanged: onRate,
                    hardLabel: l10n.sessionEffortHard,
                    normalLabel: l10n.sessionEffortNormal,
                    easyLabel: l10n.sessionEffortEasy,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Итог только что завершённой задачи. Статус — иконка и слово, не только
/// цвет (инвариант 6); верный ответ из `reveal` — у всего, что не «верно».
class OutcomeBanner extends StatelessWidget {
  const OutcomeBanner({required this.outcome, super.key});

  final TaskOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final attempt = outcome.attempt;
    final (IconData icon, String text) = switch (attempt.status) {
      AttemptStatus.timeout => (Icons.timer_off, l10n.sessionOutcomeTimeout),
      AttemptStatus.skipped => (Icons.skip_next, l10n.sessionOutcomeSkipped),
      AttemptStatus.answered => switch (attempt.isCorrect) {
        true => (Icons.check, l10n.sessionOutcomeCorrect),
        false => (Icons.close, l10n.sessionOutcomeWrong),
        null => (Icons.fact_check, l10n.sessionOutcomeSelfChecked),
      },
    };
    final reveal = attempt.isCorrect == true ? null : taskReveal(outcome.task);
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TmbColor.raised,
          borderRadius: const BorderRadius.all(
            Radius.circular(TmbRadius.sharp),
          ),
          border: Border.all(
            color: TmbColor.borderDefault,
            width: TmbStroke.base,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(TmbSpace.x3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: TmbSize.icon, color: TmbColor.textPrimary),
                  const SizedBox(width: TmbSpace.x2),
                  Expanded(
                    child: Text(
                      text.toUpperCase(),
                      style: TmbType.labelMd.copyWith(
                        color: TmbColor.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (reveal != null) ...[
                const SizedBox(height: TmbSpace.x2),
                Text(
                  l10n.sessionOutcomeReveal(reveal),
                  style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// «Эвакуация» — единственная `danger`-кнопка (DESIGN.md, правило 2). Не
/// прерывает сразу: сначала подтверждение.
class EvacuateButton extends StatelessWidget {
  const EvacuateButton({required this.controller, super.key});

  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    return TmbButton(
      label: AppLocalizations.of(context).sessionEvacuate,
      variant: TmbButtonVariant.danger,
      expand: true,
      onPressed: () async {
        if (await confirmEvacuation(context) && context.mounted) {
          await controller.evacuate();
        }
      },
    );
  }
}

/// Диалог подтверждения прерывания; `true` — прервать.
Future<bool> confirmEvacuation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => const _EvacuationDialog(),
  );
  return confirmed ?? false;
}

class _EvacuationDialog extends StatelessWidget {
  const _EvacuationDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: TmbColor.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
        side: BorderSide(color: TmbColor.borderDefault, width: TmbStroke.base),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TmbSpace.x4),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.sessionEvacuateTitle.toUpperCase(),
                  style: TmbType.displayLg.copyWith(color: TmbColor.danger),
                ),
              ),
              const SizedBox(height: TmbSpace.x3),
              Text(
                l10n.sessionEvacuateBody,
                style: TmbType.bodyMd.copyWith(color: TmbColor.textPrimary),
              ),
              const SizedBox(height: TmbSpace.x6),
              TmbButton(
                label: l10n.sessionEvacuateConfirm,
                variant: TmbButtonVariant.danger,
                expand: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: TmbSpace.x2),
              TmbButton(
                label: l10n.sessionEvacuateCancel,
                variant: TmbButtonVariant.secondary,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Верхняя граница `ExerciseSet.done` (SCHEMAS §3.3).
const _maxDone = 3600;

/// Ввод фактически сделанного: цифровая клавиатура с предзаполненным
/// предписанным значением. Первая цифра заменяет его, а не дописывается.
/// `null` — шторку закрыли без ввода.
Future<int?> showActualDoneSheet(
  BuildContext context, {
  required int initial,
  required String unitLabel,
}) => showModalBottomSheet<int>(
  context: context,
  isScrollControlled: true,
  backgroundColor: TmbColor.overlay,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(TmbRadius.sharp)),
  ),
  builder: (context) =>
      _ActualDoneSheet(initial: initial, unitLabel: unitLabel),
);

class _ActualDoneSheet extends StatefulWidget {
  const _ActualDoneSheet({required this.initial, required this.unitLabel});

  final int initial;
  final String unitLabel;

  @override
  State<_ActualDoneSheet> createState() => _ActualDoneSheetState();
}

class _ActualDoneSheetState extends State<_ActualDoneSheet> {
  late String _text = '${widget.initial}';
  var _fresh = true;

  void _digit(int d) => setState(() {
    final base = _fresh ? '' : _text;
    _fresh = false;
    final next = base == '0' ? '$d' : '$base$d';
    if ((int.tryParse(next) ?? 0) <= _maxDone) _text = next;
  });

  void _backspace() => setState(() {
    _fresh = false;
    _text = _text.isEmpty ? '' : _text.substring(0, _text.length - 1);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(_text);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TmbSpace.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sessionActualTitle.toUpperCase(),
              style: TmbType.labelLg.copyWith(color: TmbColor.textSecondary),
            ),
            const SizedBox(height: TmbSpace.x2),
            Semantics(
              liveRegion: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _text.isEmpty ? '0' : '$_text ${widget.unitLabel}',
                  style: TmbType.dataTimer.copyWith(
                    color: TmbColor.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TmbSpace.x4),
            TmbNumericKeypad(
              onDigit: _digit,
              onBackspace: _backspace,
              onSubmit: value == null
                  ? null
                  : () => Navigator.of(context).pop(value),
              backspaceLabel: l10n.sessionKeyBackspace,
              submitLabel: l10n.sessionActualConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
