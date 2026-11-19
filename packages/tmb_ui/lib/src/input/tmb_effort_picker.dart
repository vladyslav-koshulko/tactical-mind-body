import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_theme.dart';
import 'tmb_choice_tile.dart';

/// Субъективная тяжесть круга.
enum TmbEffort { hard, normal, easy }

/// «Тяжело / нормально / легко» одним нажатием. Три плитки друг под другом
/// на всю ширину: подписи не упираются в ширину экрана при крупном шрифте.
class TmbEffortPicker extends StatelessWidget {
  const TmbEffortPicker({
    required this.value,
    required this.onChanged,
    required this.hardLabel,
    required this.normalLabel,
    required this.easyLabel,
    this.phase,
    super.key,
  });

  /// Текущий выбор или `null`.
  final TmbEffort? value;
  final ValueChanged<TmbEffort> onChanged;

  final String hardLabel;
  final String normalLabel;
  final String easyLabel;

  /// `null` — наследовать фазу из темы.
  final TmbPhase? phase;

  @override
  Widget build(BuildContext context) {
    final effective = phase ?? TmbPhaseTheme.of(context).phase;
    final labels = {
      TmbEffort.hard: hardLabel,
      TmbEffort.normal: normalLabel,
      TmbEffort.easy: easyLabel,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in labels.entries) ...[
          if (entry.key != TmbEffort.hard) const SizedBox(height: TmbSpace.x2),
          TmbChoiceTile(
            title: entry.value.toUpperCase(),
            titleStyle: TmbType.labelLg,
            selected: value == entry.key,
            phase: effective,
            onPressed: () => onChanged(entry.key),
          ),
        ],
      ],
    );
  }
}
