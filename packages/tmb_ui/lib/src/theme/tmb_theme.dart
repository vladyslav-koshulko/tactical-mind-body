import 'package:material_ui/material_ui.dart';

import '../../tokens.dart';
import '../phase/tmb_phase_theme.dart';

/// Тема приложения целиком из токенов. Светлой темы не будет (см. tokens.dart).
abstract final class TmbTheme {
  /// Минимальная высота цели касания (DESIGN.md, правило 4).
  static const double minTapTarget = TmbSpace.x12;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
  );

  static ThemeData dark({TmbPhase phase = TmbPhase.physical}) {
    final scheme = ColorScheme.dark(
      primary: phase.accent,
      onPrimary: TmbColor.textInverse,
      primaryContainer: phase.surface,
      onPrimaryContainer: TmbColor.textPrimary,
      secondary: TmbColor.signal500,
      onSecondary: TmbColor.textInverse,
      secondaryContainer: TmbColor.signal900,
      onSecondaryContainer: TmbColor.textPrimary,
      tertiary: TmbColor.olive500,
      onTertiary: TmbColor.textInverse,
      error: TmbColor.danger,
      onError: TmbColor.textInverse,
      surface: TmbColor.surface,
      onSurface: TmbColor.textPrimary,
      onSurfaceVariant: TmbColor.textSecondary,
      surfaceContainerLowest: TmbColor.void_,
      surfaceContainerLow: TmbColor.surface,
      surfaceContainer: TmbColor.raised,
      surfaceContainerHigh: TmbColor.overlay,
      surfaceContainerHighest: TmbColor.overlay,
      outline: TmbColor.borderDefault,
      outlineVariant: TmbColor.borderSubtle,
    );

    // Весь текст — из шкалы TmbType; цвет задаётся здесь, не в стилях шкалы.
    final textTheme =
        TextTheme(
          displayLarge: TmbType.displayHero,
          displayMedium: TmbType.displayLg,
          displaySmall: TmbType.displayMd,
          headlineLarge: TmbType.displayHero,
          headlineMedium: TmbType.displayLg,
          headlineSmall: TmbType.displayMd,
          titleLarge: TmbType.displayLg,
          titleMedium: TmbType.displayMd,
          titleSmall: TmbType.labelLg,
          bodyLarge: TmbType.bodyLg,
          bodyMedium: TmbType.bodyMd,
          bodySmall: TmbType.bodySm,
          labelLarge: TmbType.labelLg,
          labelMedium: TmbType.labelMd,
          labelSmall: TmbType.labelSm,
        ).apply(
          bodyColor: TmbColor.textPrimary,
          displayColor: TmbColor.textPrimary,
        );

    const minSize = Size(minTapTarget, minTapTarget);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: TmbColor.void_,
      canvasColor: TmbColor.void_,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerColor: TmbColor.borderSubtle,
      cardTheme: const CardThemeData(
        color: TmbColor.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TmbRadius.sharp)),
          side: BorderSide(color: TmbColor.borderDefault),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: phase.accent,
          foregroundColor: TmbColor.textInverse,
          minimumSize: minSize,
          padding: const EdgeInsets.symmetric(
            horizontal: TmbSpace.x6,
            vertical: TmbSpace.x3,
          ),
          shape: _shape,
          textStyle: TmbType.labelLg,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TmbColor.textPrimary,
          minimumSize: minSize,
          side: const BorderSide(color: TmbColor.borderDefault),
          shape: _shape,
          textStyle: TmbType.labelLg,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: phase.accent,
          minimumSize: minSize,
          shape: _shape,
          textStyle: TmbType.labelLg,
        ),
      ),
      extensions: [TmbPhaseTheme(phase: phase)],
    );
  }
}
