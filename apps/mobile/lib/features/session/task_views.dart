import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../l10n/app_localizations.dart';
import 'session_format.dart';
import 'task_order.dart';

/// Панель с текстом задачи: условие, вопрос, запоминаемый текст.
class TaskTextCard extends StatelessWidget {
  const TaskTextCard({required this.text, this.label, super.key});

  final String text;

  /// Подпись над текстом (капс — свойство стиля).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final phase = TmbPhaseTheme.of(context).phase;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TmbColor.raised,
        borderRadius: const BorderRadius.all(Radius.circular(TmbRadius.sharp)),
        border: Border.all(color: phase.border, width: TmbStroke.base),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TmbSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null) ...[
              Text(
                label!.toUpperCase(),
                style: TmbType.labelMd.copyWith(color: phase.accent),
              ),
              const SizedBox(height: TmbSpace.x2),
            ],
            Text(
              text,
              style: TmbType.bodyLg.copyWith(color: TmbColor.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Оставшееся время стадии: цифры и полоса. Для скринридера — одна фраза.
class TaskTimeBar extends StatelessWidget {
  const TaskTimeBar({
    required this.remainingMs,
    required this.totalMs,
    super.key,
  });

  final int remainingMs;
  final int totalMs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    final time = formatMmSs(remainingMs);
    final progress = totalMs <= 0
        ? 0.0
        : (remainingMs / totalMs).clamp(0.0, 1.0);
    return Semantics(
      label: l10n.sessionTimerRemaining(time),
      excludeSemantics: true,
      child: Row(
        children: [
          Text(
            time,
            style: TmbType.dataMetric.copyWith(color: TmbColor.textPrimary),
          ),
          const SizedBox(width: TmbSpace.x3),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: TmbStroke.radar,
              color: phase.accent,
              backgroundColor: TmbColor.borderDefault,
            ),
          ),
        ],
      ),
    );
  }
}

/// Подсказка-кнопка «Ответить» для всех выборных архетипов.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TmbButton(
    label: AppLocalizations.of(context).sessionAnswerSubmit,
    onPressed: onPressed,
    expand: true,
  );
}

// --- recall / delayed_recall ------------------------------------------------

/// Ответ `recall`/`delayed_recall`: число — на своей клавиатуре, текст — в
/// поле (единственное место, где допустима системная клавиатура).
class RecallAnswerView extends StatelessWidget {
  const RecallAnswerView({
    required this.expected,
    required this.onSubmit,
    super.key,
  });

  /// Эталонный ответ задачи — по его виду выбирается способ ввода (ввод не
  /// подсказывает ответа: клавиши минуса и запятой есть всегда).
  final Object expected;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) => isNumericAnswer(expected)
      ? _NumericAnswer(onSubmit: onSubmit)
      : _TextAnswer(onSubmit: onSubmit);
}

class _NumericAnswer extends StatefulWidget {
  const _NumericAnswer({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_NumericAnswer> createState() => _NumericAnswerState();
}

class _NumericAnswerState extends State<_NumericAnswer> {
  /// Предел длины: ответ `TaskAttempt.response` ≤ 200, числа короче.
  static const _maxLength = 18;
  static const _decimal = TmbNumericKeypad.defaultDecimalSeparator;

  String _text = '';

  bool get _canSubmit => RegExp(r'^-?\d+(,\d+)?$').hasMatch(_text);

  void _digit(int d) {
    if (_text.length < _maxLength) setState(() => _text = '$_text$d');
  }

  void _backspace() {
    if (_text.isEmpty) return;
    setState(() => _text = _text.substring(0, _text.length - 1));
  }

  void _minus() => setState(() {
    _text = _text.startsWith('-') ? _text.substring(1) : '-$_text';
  });

  void _decimalSeparator() {
    final hasDigit = RegExp(r'\d$').hasMatch(_text);
    if (hasDigit && !_text.contains(_decimal)) {
      setState(() => _text = '$_text$_decimal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.sessionAnswerHint,
          value: _text,
          liveRegion: true,
          excludeSemantics: true,
          child: Container(
            constraints: const BoxConstraints(minHeight: TmbSize.keypadKey),
            padding: const EdgeInsets.symmetric(
              horizontal: TmbSpace.x4,
              vertical: TmbSpace.x2,
            ),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: TmbColor.surface,
              borderRadius: const BorderRadius.all(
                Radius.circular(TmbRadius.sharp),
              ),
              border: Border.all(color: phase.accent, width: TmbStroke.base),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _text.isEmpty ? l10n.sessionAnswerHint : _text,
                maxLines: 1,
                style: TmbType.dataTimer.copyWith(
                  color: _text.isEmpty
                      ? TmbColor.textMuted
                      : TmbColor.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: TmbSpace.x2),
        TmbNumericKeypad(
          onDigit: _digit,
          onBackspace: _backspace,
          onMinus: _minus,
          onDecimal: _decimalSeparator,
          onSubmit: _canSubmit ? () => widget.onSubmit(_text) : null,
          backspaceLabel: l10n.sessionKeyBackspace,
          submitLabel: l10n.sessionAnswerSubmit,
          minusLabel: l10n.sessionKeyMinus,
          decimalLabel: l10n.sessionKeyDecimal,
        ),
      ],
    );
  }
}

class _TextAnswer extends StatefulWidget {
  const _TextAnswer({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends State<_TextAnswer> {
  /// Предел `TaskAttempt.response` (SCHEMAS §3.4).
  static const _maxLength = 200;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  void _submit() {
    if (_canSubmit) widget.onSubmit(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(TmbRadius.sharp)),
      borderSide: BorderSide(color: color, width: TmbStroke.base),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          maxLength: _maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: TmbType.bodyLg.copyWith(color: TmbColor.textPrimary),
          cursorColor: phase.accent,
          decoration: InputDecoration(
            hintText: l10n.sessionAnswerHint,
            hintStyle: TmbType.bodyLg.copyWith(color: TmbColor.textMuted),
            counterText: '',
            filled: true,
            fillColor: TmbColor.surface,
            contentPadding: const EdgeInsets.all(TmbSpace.x4),
            enabledBorder: border(TmbColor.borderDefault),
            focusedBorder: border(phase.accent),
          ),
        ),
        const SizedBox(height: TmbSpace.x4),
        _SubmitButton(onPressed: _canSubmit ? _submit : null),
      ],
    );
  }
}

// --- delayed_recall: запоминание ---------------------------------------------

/// Стадия запоминания: текст виден, пока идёт показ или пока не нажато
/// «Запомнил».
class StudyTextView extends StatelessWidget {
  const StudyTextView({
    required this.prompt,
    required this.text,
    required this.onDone,
    super.key,
  });

  final String prompt;
  final String text;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaskTextCard(label: l10n.sessionStudyHint, text: prompt),
        const SizedBox(height: TmbSpace.x3),
        TaskTextCard(text: text),
        const SizedBox(height: TmbSpace.x4),
        TmbButton(
          label: l10n.sessionStudyDone,
          onPressed: onDone,
          expand: true,
        ),
      ],
    );
  }
}

// --- choice -------------------------------------------------------------------

/// Крупные варианты; выбор — нажатием, ответ — кнопкой «Ответить» (от
/// случайного нажатия дрожащим пальцем).
class ChoiceAnswerView extends StatefulWidget {
  const ChoiceAnswerView({
    required this.task,
    required this.seed,
    required this.onSubmit,
    super.key,
  });

  final ChoiceTask task;
  final int seed;
  final ValueChanged<TaskAnswer> onSubmit;

  @override
  State<ChoiceAnswerView> createState() => _ChoiceAnswerViewState();
}

class _ChoiceAnswerViewState extends State<ChoiceAnswerView> {
  late final List<int> _order = widget.task.shufflesOptions
      ? shuffledOrder(
          widget.task.options.length,
          seed: widget.seed,
          taskId: widget.task.id,
        )
      : List<int>.generate(widget.task.options.length, (i) => i);

  /// Исходный индекс выбранного варианта.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final phase = TmbPhaseTheme.of(context).phase;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final original in _order) ...[
          TmbChoiceTile(
            title: widget.task.options[original],
            titleStyle: TmbType.bodyLg,
            selected: _selected == original,
            phase: phase,
            onPressed: () => setState(() => _selected = original),
          ),
          const SizedBox(height: TmbSpace.x2),
        ],
        const SizedBox(height: TmbSpace.x2),
        _SubmitButton(
          onPressed: _selected == null
              ? null
              : () => widget.onSubmit(TaskAnswer.choice(_selected!)),
        ),
      ],
    );
  }
}

// --- ordering -----------------------------------------------------------------

/// Минимальное упорядочивание: шаги нажимают в нужном порядке, выбранный
/// получает номер. Нажатие на выбранный шаг снимает его и все следующие.
class OrderingAnswerView extends StatefulWidget {
  const OrderingAnswerView({
    required this.task,
    required this.seed,
    required this.onSubmit,
    super.key,
  });

  final OrderingTask task;
  final int seed;
  final ValueChanged<TaskAnswer> onSubmit;

  @override
  State<OrderingAnswerView> createState() => _OrderingAnswerViewState();
}

class _OrderingAnswerViewState extends State<OrderingAnswerView> {
  late final List<int> _order = shuffledOrder(
    widget.task.items.length,
    seed: widget.seed,
    taskId: widget.task.id,
    mustDiffer: true,
  );

  /// Исходные индексы шагов в порядке, выбранном пользователем.
  final _picked = <int>[];

  void _tap(int original) => setState(() {
    final at = _picked.indexOf(original);
    if (at >= 0) {
      _picked.removeRange(at, _picked.length);
    } else {
      _picked.add(original);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    final complete = _picked.length == widget.task.items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sessionOrderingHint,
          style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
        ),
        const SizedBox(height: TmbSpace.x3),
        for (final original in _order) ...[
          TmbChoiceTile(
            title: _picked.contains(original)
                ? '${_picked.indexOf(original) + 1}. '
                      '${widget.task.items[original]}'
                : widget.task.items[original],
            titleStyle: TmbType.bodyLg,
            selected: _picked.contains(original),
            phase: phase,
            onPressed: () => _tap(original),
          ),
          const SizedBox(height: TmbSpace.x2),
        ],
        const SizedBox(height: TmbSpace.x2),
        _SubmitButton(
          onPressed: complete
              ? () => widget.onSubmit(TaskAnswer.ordering(_picked))
              : null,
        ),
      ],
    );
  }
}

// --- spatial ------------------------------------------------------------------

/// Сетка `spatial`. На стадии показа — подписи объектов, на стадии ответа —
/// пустая сетка, клетка выбирается нажатием.
class SpatialGridView extends StatelessWidget {
  const SpatialGridView({
    required this.grid,
    this.objects = const [],
    this.selected,
    this.onCellTap,
    super.key,
  });

  final GridSize grid;

  /// Объекты, подписи которых видны (пусто — ответ).
  final List<SpatialObject> objects;
  final CellPosition? selected;

  /// `null` — сетка только для показа.
  final ValueChanged<CellPosition>? onCellTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        // Клетка не меньше цели касания; у широкой сетки — горизонтальная
        // прокрутка вместо микроскопических клеток.
        final cell = (available / grid.cols).clamp(
          TmbSize.tapTarget,
          TmbSize.keypadKey,
        );
        final gridWidth = cell * grid.cols;

        Widget buildCell(int row, int col) {
          final object = objects
              .where((o) => o.row == row && o.col == col)
              .firstOrNull;
          final isSelected = selected?.row == row && selected?.col == col;
          final position = CellPosition(row: row, col: col);
          final label = object?.label;
          return Semantics(
            button: onCellTap != null,
            selected: isSelected,
            label:
                l10n.sessionSpatialCell(row + 1, col + 1) +
                (label == null ? '' : ', $label'),
            excludeSemantics: true,
            onTap: onCellTap == null ? null : () => onCellTap!(position),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCellTap == null ? null : () => onCellTap!(position),
              child: Container(
                width: cell,
                height: cell,
                decoration: BoxDecoration(
                  color: isSelected ? phase.surface : TmbColor.raised,
                  border: Border.all(
                    color: isSelected || object != null
                        ? phase.accent
                        : TmbColor.borderDefault,
                    width: TmbStroke.base,
                  ),
                ),
                padding: const EdgeInsets.all(TmbSpace.x1),
                alignment: Alignment.center,
                child: isSelected
                    ? Icon(Icons.check, size: TmbSize.icon, color: phase.accent)
                    : label == null
                    ? null
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: TmbType.bodySm.copyWith(
                            color: TmbColor.textPrimary,
                          ),
                        ),
                      ),
              ),
            ),
          );
        }

        final table = SizedBox(
          width: gridWidth,
          child: Column(
            children: [
              for (var r = 0; r < grid.rows; r++)
                Row(
                  children: [
                    for (var c = 0; c < grid.cols; c++) buildCell(r, c),
                  ],
                ),
            ],
          ),
        );
        if (gridWidth <= available) return Center(child: table);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }
}

/// Стадия ответа `spatial`: сетка и «Ответить».
class SpatialAnswerView extends StatefulWidget {
  const SpatialAnswerView({
    required this.task,
    required this.onSubmit,
    super.key,
  });

  final SpatialTask task;
  final ValueChanged<TaskAnswer> onSubmit;

  @override
  State<SpatialAnswerView> createState() => _SpatialAnswerViewState();
}

class _SpatialAnswerViewState extends State<SpatialAnswerView> {
  CellPosition? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cell = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sessionSpatialAnswerHint,
          style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
        ),
        const SizedBox(height: TmbSpace.x3),
        SpatialGridView(
          grid: widget.task.grid,
          selected: cell,
          onCellTap: (c) => setState(() => _selected = c),
        ),
        const SizedBox(height: TmbSpace.x4),
        _SubmitButton(
          onPressed: cell == null
              ? null
              : () => widget.onSubmit(
                  TaskAnswer.spatial(row: cell.row, col: cell.col),
                ),
        ),
      ],
    );
  }
}

/// Стадия показа `spatial`: подписи на сетке и «Запомнил».
class SpatialStudyView extends StatelessWidget {
  const SpatialStudyView({required this.task, required this.onDone, super.key});

  final SpatialTask task;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sessionSpatialStudyHint,
          style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
        ),
        const SizedBox(height: TmbSpace.x3),
        SpatialGridView(grid: task.grid, objects: task.objects ?? const []),
        const SizedBox(height: TmbSpace.x4),
        TmbButton(
          label: l10n.sessionStudyDone,
          onPressed: onDone,
          expand: true,
        ),
      ],
    );
  }
}

// --- verbal -------------------------------------------------------------------

/// `verbal`: речь вслух с таймером и подсказками `cues`, затем самопроверка
/// «да/нет». Машина ответа не оценивает (инвариант 7): наружу уходит только
/// число «да».
class VerbalView extends StatefulWidget {
  const VerbalView({
    required this.task,
    required this.cues,
    required this.selfCheckStage,
    required this.onSubmit,
    super.key,
  });

  final VerbalTask task;

  /// Подсказки, чей момент уже наступил.
  final List<DueCue> cues;

  /// Движок уже перевёл задачу в самопроверку (время речи вышло).
  final bool selfCheckStage;
  final ValueChanged<TaskAnswer> onSubmit;

  @override
  State<VerbalView> createState() => _VerbalViewState();
}

class _VerbalViewState extends State<VerbalView> {
  /// Пользователь закончил речь раньше срока.
  var _finishedEarly = false;
  late final List<bool?> _answers = List.filled(
    widget.task.selfCheck.length,
    null,
  );

  @override
  Widget build(BuildContext context) {
    final checking = _finishedEarly || widget.selfCheckStage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.cues.isNotEmpty) ...[
          _CueList(cues: widget.cues),
          const SizedBox(height: TmbSpace.x4),
        ],
        if (checking) _selfCheck(context) else _speech(context),
      ],
    );
  }

  Widget _speech(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sessionVerbalSpeak.toUpperCase(),
          style: TmbType.labelLg.copyWith(
            color: TmbPhaseTheme.of(context).phase.accent,
          ),
        ),
        const SizedBox(height: TmbSpace.x4),
        TmbButton(
          label: l10n.sessionVerbalFinish,
          onPressed: () => setState(() => _finishedEarly = true),
          expand: true,
        ),
      ],
    );
  }

  Widget _selfCheck(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    final complete = _answers.every((a) => a != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sessionVerbalSelfCheckTitle.toUpperCase(),
          style: TmbType.labelLg.copyWith(color: phase.accent),
        ),
        const SizedBox(height: TmbSpace.x1),
        Text(
          l10n.sessionVerbalSelfCheckHint,
          style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
        ),
        const SizedBox(height: TmbSpace.x3),
        for (var i = 0; i < _answers.length; i++) ...[
          TaskTextCard(text: widget.task.selfCheck[i]),
          const SizedBox(height: TmbSpace.x2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TmbChoiceTile(
                    title: l10n.sessionYes.toUpperCase(),
                    titleStyle: TmbType.labelLg,
                    selected: _answers[i] == true,
                    phase: phase,
                    onPressed: () => setState(() => _answers[i] = true),
                  ),
                ),
                const SizedBox(width: TmbSpace.x2),
                Expanded(
                  child: TmbChoiceTile(
                    title: l10n.sessionNo.toUpperCase(),
                    titleStyle: TmbType.labelLg,
                    selected: _answers[i] == false,
                    phase: phase,
                    onPressed: () => setState(() => _answers[i] = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TmbSpace.x3),
        ],
        _SubmitButton(
          onPressed: complete
              ? () => widget.onSubmit(
                  TaskAnswer.selfCheck(
                    yes: _answers.where((a) => a == true).length,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

/// Подсказки посреди задачи («смена правила»). Заметны без цвета: иконка,
/// подпись и толстая рамка; свежая — самая верхняя и с акцентной рамкой.
class _CueList extends StatelessWidget {
  const _CueList({required this.cues});

  final List<DueCue> cues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = TmbPhaseTheme.of(context).phase;
    final newestFirst = cues.reversed.toList();
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < newestFirst.length; i++) ...[
            if (i > 0) const SizedBox(height: TmbSpace.x2),
            DecoratedBox(
              decoration: BoxDecoration(
                color: i == 0 ? phase.surface : TmbColor.raised,
                borderRadius: const BorderRadius.all(
                  Radius.circular(TmbRadius.sharp),
                ),
                border: Border.all(
                  color: i == 0 ? phase.accent : TmbColor.borderDefault,
                  width: TmbStroke.base,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(TmbSpace.x3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: TmbSize.icon,
                      color: i == 0 ? phase.accent : TmbColor.textSecondary,
                    ),
                    const SizedBox(width: TmbSpace.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sessionCueTitle.toUpperCase(),
                            style: TmbType.labelMd.copyWith(
                              color: i == 0
                                  ? phase.accent
                                  : TmbColor.textSecondary,
                            ),
                          ),
                          const SizedBox(height: TmbSpace.x1),
                          Text(
                            newestFirst[i].text,
                            style: TmbType.bodyLg.copyWith(
                              color: TmbColor.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
