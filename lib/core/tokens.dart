import 'package:flutter/material.dart';

/// Single source of truth for every color, duration, curve, spacing,
/// radius and breakpoint in the app. No hex code, Duration, or Curve
/// literal may appear anywhere else in the codebase — reference these
/// constants instead.

abstract final class AppColors {
  // Dark (default boot theme) — exact PRD values.
  static const darkBg = Color(0xFF0A0E1A);
  static const darkBgRaised = Color(0xFF111729);
  static const darkBgSunken = Color(0xFF070A13);
  static const darkLine = Color(0xFF1E2740);
  static const darkTextPrimary = Color(0xFFE6EAF2);
  static const darkTextSecondary = Color(0xFF8A94AD);
  static const darkTextMuted = Color(0xFF545E78);

  // Light — same accent hues, bg/line/text inverted (no PRD spec; authored
  // for this project's kept light-mode toggle).
  static const lightBg = Color(0xFFF7F9FC);
  static const lightBgRaised = Color(0xFFFFFFFF);
  static const lightBgSunken = Color(0xFFEDF1F7);
  static const lightLine = Color(0xFFD7DEEA);
  static const lightTextPrimary = Color(0xFF0F1424);
  static const lightTextSecondary = Color(0xFF4B5570);
  static const lightTextMuted = Color(0xFF7C879E);

  // Shared accents (both themes) — NetLayer colors.
  static const netCyan = Color(0xFF22D3EE);
  static const apiViolet = Color(0xFFA78BFA);
  static const dbAmber = Color(0xFFF59E0B);
  static const okGreen = Color(0xFF4ADE80);
  static const errRed = Color(0xFFF87171);
  static const warnOrange = Color(0xFFFB923C);

  static const glowOpacity = 0.35;
  static const glowBlurSigma = 12.0;
}

/// A resolved palette for the active brightness, read via
/// `AppPalette.of(context)`.
class AppPalette {
  final Color bg;
  final Color bgRaised;
  final Color bgSunken;
  final Color line;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const AppPalette({
    required this.bg,
    required this.bgRaised,
    required this.bgSunken,
    required this.line,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const dark = AppPalette(
    bg: AppColors.darkBg,
    bgRaised: AppColors.darkBgRaised,
    bgSunken: AppColors.darkBgSunken,
    line: AppColors.darkLine,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
  );

  static const light = AppPalette(
    bg: AppColors.lightBg,
    bgRaised: AppColors.lightBgRaised,
    bgSunken: AppColors.lightBgSunken,
    line: AppColors.lightLine,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Font family name indirection. No font assets are bundled yet (TODO(content)
/// in docs/AUDIT.md) — these resolve to the platform default until the real
/// JetBrains Mono / Space Grotesk files are supplied, at which point only
/// this file changes.
abstract final class AppFonts {
  static const String? display = null;
  static const String? mono = null;
}

abstract final class AppType {
  static const display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 64,
    height: 1.05,
    fontWeight: FontWeight.w700,
  );
  static const displayMobile = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 40,
    height: 1.05,
    fontWeight: FontWeight.w700,
  );
  static const h1 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );
  static const h1Mobile = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );
  static const h2 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static const h2Mobile = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 17,
    height: 1.6,
    fontWeight: FontWeight.w500,
  );
  static const mono = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const monoLabel = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.96, // 0.08em at 12px
    fontWeight: FontWeight.w700,
  );
}

abstract final class AppSpacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;
  static const s64 = 64.0;
  static const s96 = 96.0;
  static const s128 = 128.0;
}

abstract final class AppRadii {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

/// Scene layout constants that aren't part of the generic spacing scale
/// (the gutter reserved for the request path + Pak, and per-section
/// vertical padding) — verbatim from the PRD's layout rules.
abstract final class AppLayout {
  static const mobileGutter = 28.0;
  static const desktopGutter = AppSpacing.s96;
  static const mobileSectionPadding = 80.0;
  static const desktopSectionPadding = AppSpacing.s128;
  static const mobilePathWidth = 2.0;
  static const mobilePakSize = 40.0;
}

abstract final class AppBreakpoints {
  static const mobileMax = 720.0;
  static const tabletMax = 1100.0;
  static const maxContentWidth = 1120.0;

  static bool isMobile(double width) => width < mobileMax;
  static bool isTablet(double width) => width >= mobileMax && width < tabletMax;
  static bool isDesktop(double width) => width >= tabletMax;
}

/// Motion durations and curves — verbatim from the PRD.
abstract final class Motion {
  static const press = Duration(milliseconds: 90);
  static const handshake = Duration(milliseconds: 300);
  static const ping = Duration(milliseconds: 600);
  static const badgeFloat = Duration(milliseconds: 800);
  static const traceDraw = Duration(milliseconds: 400);
  static const navScrollMin = Duration(milliseconds: 700);
  static const navScrollMax = Duration(milliseconds: 1100);
  static const redirect = Duration(milliseconds: 350);
  static const reveal = Duration(milliseconds: 500);
  static const teardownStep = Duration(milliseconds: 380);
  static const keepAlive = Duration(milliseconds: 1000);
  static const layerBlend = Duration(milliseconds: 450);

  static const out = Curves.easeOutCubic;
  static const outQuart = Curves.easeOutQuart;
  static const inOut = Curves.easeInOutCubic;
  static const back = Curves.easeOutBack;
}
