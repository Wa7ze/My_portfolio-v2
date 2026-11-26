import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/reduced_motion.dart';
import '../core/tokens.dart';
import '../interaction/effects_controller.dart';
import '../scene/request_path.dart';
import '../scroll/scroll_progress.dart';
import 'hash_sync.dart';
import 'section_registry.dart';

/// Drives section-to-section navigation: scrolls to the target section
/// (duration scaled within [Motion.navScrollMin]-[Motion.navScrollMax] by
/// distance) and fires a traceroute highlight along the path between the
/// current and target sections.
class NavController extends ChangeNotifier {
  SectionId _activeSection = SectionId.browserHero;
  SectionId get activeSection => _activeSection;

  void goTo(BuildContext context, SectionId id, {Duration? fixedDuration}) {
    final targetContext = SectionRegistry.keyFor(id).currentContext;
    if (targetContext == null) return;

    final scrollProgress = context.read<ScrollProgress>();
    final fromSection = scrollProgress.activeSection;
    final reduced = MotionPrefs.of(context).reduced;

    if (!reduced) {
      final width = MediaQuery.sizeOf(context).width;
      final gutterWidth = AppBreakpoints.isMobile(width) ? AppLayout.mobileGutter : AppLayout.desktopGutter;
      final direction = Directionality.of(context);
      final path = RequestPath.build(gutterWidth: gutterWidth, direction: direction);

      context.read<EffectsController>().setTraceroute(
            path.lengthForStation(fromSection),
            path.lengthForStation(id),
          );
    }

    Duration duration;
    if (reduced) {
      duration = const Duration(milliseconds: 200);
    } else if (fixedDuration != null) {
      duration = fixedDuration;
    } else {
      final currentOffset = Scrollable.of(targetContext).position.pixels;
      final targetOffset = SectionRegistry.offsetFor(id);
      final maxScroll = Scrollable.of(targetContext).position.maxScrollExtent;
      final fraction = maxScroll > 0 ? ((targetOffset - currentOffset).abs() / maxScroll).clamp(0.0, 1.0) : 0.0;
      final durationMs = Motion.navScrollMin.inMilliseconds +
          (Motion.navScrollMax.inMilliseconds - Motion.navScrollMin.inMilliseconds) * fraction;
      duration = Duration(milliseconds: durationMs.round());
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: duration,
      curve: Motion.inOut,
    );

    _activeSection = id;
    HashSync.onNavigate(id);
    notifyListeners();
  }
}
