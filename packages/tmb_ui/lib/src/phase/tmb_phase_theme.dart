import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';

/// Расширение темы: текущая фаза экрана и её акцентные цвета.
///
/// Сам enum [TmbPhase] живёт в `tokens.dart` (источник правды по цветам фазы) —
/// здесь он не дублируется. Цвет — только один из двух каналов: второй канал
/// (форма) рисует `TmbPhaseGlyph`, см. инвариант 6 в CLAUDE.md.
@immutable
class TmbPhaseTheme extends ThemeExtension<TmbPhaseTheme> {
  const TmbPhaseTheme({this.phase = TmbPhase.physical});

  final TmbPhase phase;

  Color get accent => phase.accent;
  Color get surface => phase.surface;
  Color get border => phase.border;

  /// Достаёт расширение из темы; без него — физическая фаза по умолчанию.
  static TmbPhaseTheme of(BuildContext context) =>
      Theme.of(context).extension<TmbPhaseTheme>() ?? const TmbPhaseTheme();

  @override
  TmbPhaseTheme copyWith({TmbPhase? phase}) =>
      TmbPhaseTheme(phase: phase ?? this.phase);

  /// Фаза дискретна, интерполировать нечего: переключаемся на середине.
  @override
  TmbPhaseTheme lerp(ThemeExtension<TmbPhaseTheme>? other, double t) {
    if (other is! TmbPhaseTheme) return this;
    return t < 0.5 ? this : other;
  }
}
