import 'package:flutter/material.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';

/// Shared per-section layout: registers the section's [GlobalKey] (so
/// [SectionRegistry] can measure its scroll offset), reserves the
/// leading gutter for the scroll scene's request path + Pak, centers
/// content at the max content width, and renders the section's
/// English-only protocol/status label as an eyebrow above its content.
class SectionScaffold extends StatelessWidget {
  final SectionId id;
  final String statusLabel;
  final Widget child;

  const SectionScaffold({
    super.key,
    required this.id,
    required this.statusLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);
    final palette = AppPalette.of(context);

    return Container(
      key: SectionRegistry.keyFor(id),
      width: double.infinity,
      constraints: id == SectionId.browserHero
          ? BoxConstraints(minHeight: MediaQuery.sizeOf(context).height)
          : null,
      padding: EdgeInsetsDirectional.only(
        start: isMobile ? AppLayout.mobileGutter : AppLayout.desktopGutter,
        end: isMobile ? AppSpacing.s16 : AppSpacing.s32,
        top: isMobile ? AppLayout.mobileSectionPadding : AppLayout.desktopSectionPadding,
        bottom: isMobile ? AppLayout.mobileSectionPadding : AppLayout.desktopSectionPadding,
      ),
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusLabel,
              textDirection: TextDirection.ltr,
              style: AppType.monoLabel.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.s24),
            child,
          ],
        ),
      ),
    );
  }
}
