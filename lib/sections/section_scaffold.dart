import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/reduced_motion.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';
import '../scroll/scroll_progress.dart';

/// Shared per-section layout: registers the section's [GlobalKey] (so
/// [SectionRegistry] can measure its scroll offset), reserves the
/// leading gutter for the scroll scene's request path + Pak, centers
/// content at the max content width, renders the section's English-only
/// protocol/status label as an eyebrow above its content, and plays a
/// one-time fade+slide reveal the first time [ScrollProgress] marks this
/// section as reached.
class SectionScaffold extends StatefulWidget {
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
  State<SectionScaffold> createState() => _SectionScaffoldState();
}

class _SectionScaffoldState extends State<SectionScaffold> with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;
  bool _hasRevealed = false;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(vsync: this, duration: Motion.reveal);
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);
    final palette = AppPalette.of(context);
    final isRevealed = context.watch<ScrollProgress>().revealed.contains(widget.id);
    final reduced = MotionPrefs.of(context).reduced;

    if (isRevealed && !_hasRevealed) {
      _hasRevealed = true;
      reduced ? _reveal.value = 1 : _reveal.forward();
    }

    return Container(
      key: SectionRegistry.keyFor(widget.id),
      width: double.infinity,
      constraints: widget.id == SectionId.browserHero
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
        child: AnimatedBuilder(
          animation: _reveal,
          builder: (context, content) {
            final t = Motion.out.transform(_reveal.value);
            return Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: content),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.statusLabel,
                textDirection: TextDirection.ltr,
                style: AppType.monoLabel.copyWith(color: palette.textMuted),
              ),
              const SizedBox(height: AppSpacing.s24),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}
