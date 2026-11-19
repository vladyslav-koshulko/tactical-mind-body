import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_theme.dart';
import 'tmb_choice_tile.dart';

/// Самооценка 0–3 для verbal-задач (они не проверяются машиной, инвариант 7:
/// оценка не влияет на Индекс). Четыре плитки в ряд, выбор — одним нажатием.
class TmbSelfRatingBar extends StatelessWidget {
  const TmbSelfRatingBar({
    required this.value,
    required this.onChanged,
    required this.labels,
    this.phase,
    super.key,
  }) : assert(labels.length == count, 'нужно ровно $count подписей');

  /// Число вариантов: оценки `0..3`.
  static const count = 4;

  /// Текущая оценка или `null`, если ещё не выбрана.
  final int? value;
  final ValueChanged<int> onChanged;

  /// Подписи под цифрами 0, 1, 2, 3 (из ARB); капс делает виджет.
  final List<String> labels;

  /// `null` — наследовать фазу из темы.
  final TmbPhase? phase;

  @override
  Widget build(BuildContext context) {
    final effective = phase ?? TmbPhaseTheme.of(context).phase;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: TmbSpace.x2),
            Expanded(
              child: TmbChoiceTile(
                title: '$i',
                titleStyle: TmbType.dataMetric,
                caption: labels[i],
                selected: value == i,
                phase: effective,
                onPressed: () => onChanged(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
