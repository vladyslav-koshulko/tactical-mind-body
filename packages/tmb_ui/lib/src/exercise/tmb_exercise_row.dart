import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_theme.dart';

/// Состояние упражнения в круге.
enum TmbExerciseStatus {
  /// Выполнено: галочка в рамке, название зачёркнуто и приглушено.
  done,

  /// Идёт сейчас: толстая рамка цвета фазы и маркер-стрелка.
  current,

  /// Впереди: пустой квадрат-маркер.
  upcoming,
}

/// Данные строки упражнения. Все тексты приходят готовыми.
@immutable
class TmbExerciseItem {
  const TmbExerciseItem({
    required this.name,
    required this.targetValue,
    required this.targetUnit,
    required this.status,
    required this.statusLabel,
  });

  /// Название упражнения («Отжимания»); капс делает виджет.
  final String name;

  /// Цель числом: 20 (повторений) или 45 (секунд).
  final int targetValue;

  /// Единица цели текстом из ARB («повт.», «с»).
  final String targetUnit;

  final TmbExerciseStatus status;

  /// Словесное состояние для скринридера («Выполнено», «Текущее», «Впереди»).
  final String statusLabel;
}

/// Строка упражнения. Состояние читается без цвета (инвариант 6): форма
/// маркера, толщина рамки и зачёркивание дублируют оттенок.
class TmbExerciseRow extends StatelessWidget {
  const TmbExerciseRow({required this.item, this.phase, super.key});

  final TmbExerciseItem item;

  /// `null` — наследовать фазу из темы.
  final TmbPhase? phase;

  @override
  Widget build(BuildContext context) {
    final effective = phase ?? TmbPhaseTheme.of(context).phase;
    final status = item.status;
    final isCurrent = status == TmbExerciseStatus.current;
    final isDone = status == TmbExerciseStatus.done;

    final nameColor = switch (status) {
      TmbExerciseStatus.done => TmbColor.textMuted,
      TmbExerciseStatus.current => TmbColor.textPrimary,
      TmbExerciseStatus.upcoming => TmbColor.textSecondary,
    };
    final decoration = isDone ? TextDecoration.lineThrough : null;

    return Semantics(
      label:
          '${item.statusLabel}, ${item.name}, '
          '${item.targetValue} ${item.targetUnit}',
      selected: isCurrent,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: TmbSize.tapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: TmbSpace.x3,
          vertical: TmbSpace.x2,
        ),
        decoration: BoxDecoration(
          color: isCurrent ? effective.surface : TmbColor.raised,
          borderRadius: const BorderRadius.all(
            Radius.circular(TmbRadius.sharp),
          ),
          // Толщина одна и та же у всех состояний — строки не «прыгают».
          border: Border.all(
            color: isCurrent ? effective.accent : TmbColor.borderSubtle,
            width: TmbStroke.base,
          ),
        ),
        child: Row(
          children: [
            _Marker(status: status, phase: effective),
            const SizedBox(width: TmbSpace.x3),
            Expanded(
              child: Text(
                item.name.toUpperCase(),
                style: TmbType.displayMd.copyWith(
                  color: nameColor,
                  decoration: decoration,
                  decorationColor: nameColor,
                ),
              ),
            ),
            const SizedBox(width: TmbSpace.x3),
            Flexible(
              child: Text(
                '${item.targetValue} ${item.targetUnit}',
                textAlign: TextAlign.end,
                style: TmbType.dataMono.copyWith(
                  color: isCurrent ? effective.accent : nameColor,
                  decoration: decoration,
                  decorationColor: nameColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Маркер состояния: три разные формы в одном квадрате [TmbSize.marker].
class _Marker extends StatelessWidget {
  const _Marker({required this.status, required this.phase});

  final TmbExerciseStatus status;
  final TmbPhase phase;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: TmbSize.marker,
      child: switch (status) {
        TmbExerciseStatus.done => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: TmbColor.textMuted,
              width: TmbStroke.thin,
            ),
          ),
          child: const Icon(
            Icons.check,
            size: TmbSize.marker - 2 * TmbStroke.base,
            color: TmbColor.textMuted,
          ),
        ),
        TmbExerciseStatus.current => Icon(
          Icons.play_arrow,
          size: TmbSize.marker,
          color: phase.accent,
        ),
        TmbExerciseStatus.upcoming => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: TmbColor.borderDefault,
              width: TmbStroke.base,
            ),
          ),
        ),
      },
    );
  }
}

/// Список упражнений круга. Не скроллится сам — кладётся в родителя со
/// скроллом (`ListView`/`SingleChildScrollView`) или `Expanded`.
class TmbRoundList extends StatelessWidget {
  const TmbRoundList({required this.items, this.title, this.phase, super.key});

  final List<TmbExerciseItem> items;

  /// Заголовок круга («Круг 2 из 5»); капс делает виджет.
  final String? title;

  /// `null` — наследовать фазу из темы.
  final TmbPhase? phase;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!.toUpperCase(),
            style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
          ),
          const SizedBox(height: TmbSpace.x2),
        ],
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: TmbSpace.x2),
          TmbExerciseRow(item: items[i], phase: phase),
        ],
      ],
    );
  }
}
