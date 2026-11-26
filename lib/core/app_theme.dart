import 'package:flutter/material.dart';
import 'tokens.dart';

/// Builds the light/dark [ThemeData] pair from [AppColors]/[AppType].
/// Replaces the old google_fonts-based core/theme.dart.
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);
  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final onBg = palette.textPrimary;

    return base.copyWith(
      scaffoldBackgroundColor: palette.bg,
      canvasColor: palette.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.netCyan,
        onPrimary: palette.bg,
        secondary: AppColors.apiViolet,
        onSecondary: palette.bg,
        error: AppColors.errRed,
        onError: palette.bg,
        surface: palette.bgRaised,
        onSurface: onBg,
      ),
      dividerColor: palette.line,
      textTheme: TextTheme(
        displayLarge: AppType.display.copyWith(color: onBg),
        displayMedium: AppType.displayMobile.copyWith(color: onBg),
        headlineLarge: AppType.h1.copyWith(color: onBg),
        headlineMedium: AppType.h1Mobile.copyWith(color: onBg),
        titleLarge: AppType.h2.copyWith(color: onBg),
        titleMedium: AppType.h2Mobile.copyWith(color: onBg),
        bodyLarge: AppType.body.copyWith(color: onBg),
        bodyMedium: AppType.mono.copyWith(color: palette.textSecondary),
        labelLarge: AppType.monoLabel.copyWith(color: palette.textSecondary),
      ),
    );
  }
}
