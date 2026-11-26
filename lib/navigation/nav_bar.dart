import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../interaction/interactive.dart';
import '../scroll/scroll_progress.dart';
import '../widgets/terminal_launcher.dart';
import 'nav_controller.dart';
import 'section_registry.dart';

/// Every section a nav item targets, in order (the footer isn't a nav
/// target).
const _navTargets = [
  SectionId.browserHero,
  SectionId.networkAbout,
  SectionId.gatewaySkills,
  SectionId.apiProjects,
  SectionId.logicApproach,
  SectionId.databaseExperience,
  SectionId.responseContact,
];

String _labelFor(SectionId id, AppStrings strings) {
  switch (id) {
    case SectionId.browserHero:
      return strings.navHome;
    case SectionId.networkAbout:
      return strings.navAbout;
    case SectionId.gatewaySkills:
      return strings.navSkills;
    case SectionId.apiProjects:
      return strings.navWork;
    case SectionId.logicApproach:
      return strings.navApproach;
    case SectionId.databaseExperience:
      return strings.navExperience;
    case SectionId.responseContact:
    case SectionId.teardownFooter:
      return strings.navContact;
  }
}

/// Fixed top nav bar: blurred translucent background, a `<xx/>`-style logo, nav
/// items with an active LED+underline bound to [ScrollProgress.activeSection],
/// and the kept theme/locale toggles (the only UI for them now that the
/// old sidebar is gone). Collapses to a dropdown sheet under
/// [AppBreakpoints.mobileMax], reusing [SidebarController] for open/close
/// state.
class NavBar extends StatelessWidget {
  const NavBar({super.key});

  static const double height = 64.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);
    final palette = AppPalette.of(context);
    final sidebar = context.watch<SidebarController>();

    // NavBar lives in MaterialApp.router's `builder`, outside any
    // Scaffold, so IconButton/ListTile's ink effects have no Material
    // ancestor to find without this.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: palette.bgRaised.withValues(alpha: 0.8),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: isMobile ? AppSpacing.s16 : AppSpacing.s32,
                  ),
                  child: Row(
                    children: [
                      const _Logo(),
                      const Spacer(),
                      if (isMobile)
                        Interactive(
                          child: IconButton(
                            icon: Icon(
                              sidebar.isOpen ? Icons.close : Icons.menu,
                              color: palette.textPrimary,
                            ),
                            onPressed: sidebar.toggle,
                          ),
                        )
                      else ...[
                        const _NavItemsRow(),
                        const SizedBox(width: AppSpacing.s24),
                        const _ThemeToggle(),
                        const SizedBox(width: AppSpacing.s12),
                        const _LocaleToggle(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isMobile && sidebar.isOpen) const _MobileSheet(),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Interactive(
      child: GestureDetector(
        onTap:
            () => context.read<NavController>().goTo(
              context,
              SectionId.browserHero,
            ),
        onLongPress: () => context.read<TerminalLauncherController>().requestOpen(),
        child: Text(
          '<mm/>',
          textDirection: TextDirection.ltr,
          style: AppType.mono.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NavItemsRow extends StatelessWidget {
  const _NavItemsRow();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final activeSection = context.watch<ScrollProgress>().activeSection;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in _navTargets)
          _NavItem(
            id: id,
            label: _labelFor(id, strings),
            isActive: id == activeSection,
          ),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  final SectionId id;
  final String label;
  final bool isActive;
  const _NavItem({
    required this.id,
    required this.label,
    required this.isActive,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final accent = AppColors.netCyan;
    return Interactive(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => context.read<NavController>().goTo(context, widget.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppType.body.copyWith(
                    fontSize: 14,
                    color:
                        widget.isActive
                            ? accent
                            : (_hovered
                                ? palette.textPrimary
                                : palette.textSecondary),
                    fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 2,
                  width: widget.isActive ? 16 : 0,
                  color: accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final palette = AppPalette.of(context);
    // No `tooltip:` — IconButton's Tooltip needs an Overlay ancestor, but
    // NavBar lives in MaterialApp.router's `builder`, outside the Router's
    // own Navigator/Overlay. Semantics keeps the accessibility label.
    return Interactive(
      child: Semantics(
        label:
            themeController.isDark
                ? context.strings.sidebarThemeDark
                : context.strings.sidebarThemeLight,
        child: IconButton(
          icon: Icon(
            themeController.isDark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            color: palette.textSecondary,
            size: 20,
          ),
          onPressed: themeController.toggle,
        ),
      ),
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle();

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LocalePill(
          label: 'EN',
          isActive: localeController.locale.languageCode == 'en',
          onTap: () => localeController.setLocale(const Locale('en')),
        ),
        const SizedBox(width: AppSpacing.s8),
        _LocalePill(
          label: 'AR',
          isActive: localeController.locale.languageCode == 'ar',
          onTap: () => localeController.setLocale(const Locale('ar')),
        ),
      ],
    );
  }
}

class _LocalePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _LocalePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Interactive(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.netCyan : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.netCyan : palette.line,
            ),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Text(
            label,
            textDirection: TextDirection.ltr,
            style: AppType.monoLabel.copyWith(
              color: isActive ? palette.bg : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileSheet extends StatelessWidget {
  const _MobileSheet();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final activeSection = context.watch<ScrollProgress>().activeSection;
    final sidebar = context.read<SidebarController>();

    // ListTile wants an opaque Material ancestor for its background/ink —
    // the outer NavBar Material is transparency-type, so give this sheet
    // its own opaque one.
    return Material(
      color: palette.bgRaised.withValues(alpha: 0.98),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s16,
          horizontal: AppSpacing.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final id in _navTargets)
              Interactive(
                child: ListTile(
                  title: Text(
                    _labelFor(id, strings),
                    style: AppType.body.copyWith(
                      color:
                          id == activeSection
                              ? AppColors.netCyan
                              : palette.textPrimary,
                      fontWeight:
                          id == activeSection
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    context.read<NavController>().goTo(context, id);
                    sidebar.close();
                  },
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const _ThemeToggle(), const _LocaleToggle()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
