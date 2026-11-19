import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

void main() {
  final theme = TmbTheme.dark();

  test('цветовая схема берётся из TmbColor', () {
    final s = theme.colorScheme;
    expect(s.brightness, Brightness.dark);
    expect(s.primary, TmbColor.accent500);
    expect(s.onPrimary, TmbColor.textInverse);
    expect(s.secondary, TmbColor.signal500);
    expect(s.surface, TmbColor.surface);
    expect(s.onSurface, TmbColor.textPrimary);
    expect(s.error, TmbColor.danger);
    expect(s.outline, TmbColor.borderDefault);
    expect(theme.scaffoldBackgroundColor, TmbColor.void_);
  });

  test('когнитивная фаза переключает акцент на signal500', () {
    final cognitive = TmbTheme.dark(phase: TmbPhase.cognitive);
    expect(cognitive.colorScheme.primary, TmbColor.signal500);
    expect(cognitive.extension<TmbPhaseTheme>()!.accent, TmbColor.signal500);
    expect(theme.extension<TmbPhaseTheme>()!.accent, TmbColor.accent500);
  });

  test('типографика из TmbType, шрифты — по имени семейства', () {
    expect(theme.textTheme.labelLarge!.fontFamily, TmbFont.display);
    expect(theme.textTheme.labelLarge!.fontSize, TmbType.labelLg.fontSize);
    expect(theme.textTheme.bodyMedium!.fontFamily, TmbFont.mono);
    expect(
      theme.textTheme.displayLarge!.fontSize,
      TmbType.displayHero.fontSize,
    );
  });

  test('кнопки не ниже 48 и с острым скруглением', () {
    final style = theme.filledButtonTheme.style!;
    expect(
      style.minimumSize!.resolve({}),
      const Size(TmbTheme.minTapTarget, TmbTheme.minTapTarget),
    );
    expect(TmbTheme.minTapTarget, greaterThanOrEqualTo(48));
    expect(
      style.shape!.resolve({}),
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
      ),
    );
  });
}
