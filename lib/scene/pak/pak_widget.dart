import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../core/reduced_motion.dart';
import '../../core/tokens.dart';
import '../../scroll/layers.dart';
import '../../scroll/scroll_progress.dart';
import '../request_path.dart';
import 'pak_painter.dart';
import 'pak_state.dart';

/// Pak itself: a single [Ticker] reads [ScrollProgress] + [PakController]
/// every frame and eases Pak's displayed position toward the scroll-driven
/// target (a "watery" follow rather than an instant snap), pushing the
/// result into a [ValueNotifier] that drives repaints — no `setState` is
/// ever called on the animation hot path.
class PakWidget extends StatefulWidget {
  const PakWidget({super.key});

  @override
  State<PakWidget> createState() => _PakWidgetState();
}

class _PakWidgetState extends State<PakWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ValueNotifier<PakVisual> _visual;
  ScrollProgress? _scrollProgress;
  PakController? _pakController;
  RequestPath? _path;
  double _displayedLength = 0;
  bool _reduced = false;

  static const double _followFactor = 0.12;

  @override
  void initState() {
    super.initState();
    _visual = ValueNotifier(
      const PakVisual(position: Offset.zero, mood: PakMood.idle, facing: 1, accent: AppColors.netCyan),
    );
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollProgress = Provider.of<ScrollProgress>(context, listen: false);
    _pakController = Provider.of<PakController>(context, listen: false);
    _reduced = MotionPrefs.of(context).reduced;
  }

  void _onTick(Duration elapsed) {
    final scrollProgress = _scrollProgress;
    final pak = _pakController;
    final path = _path;
    if (scrollProgress == null || pak == null || path == null || path.totalLength == 0) return;

    final targetLength = scrollProgress.progress * path.totalLength;
    _displayedLength += _reduced ? (targetLength - _displayedLength) : (targetLength - _displayedLength) * _followFactor;
    final position = path.positionAtLength(_displayedLength);
    final accent = NetLayers.accentFor(scrollProgress.activeLayer);
    final speed = (targetLength - _displayedLength).abs();

    Offset? gazeOffset;
    final gazeTarget = pak.gazeTarget;
    if (gazeTarget != null && pak.currentMood == PakMood.lookingAt) {
      final delta = gazeTarget - position;
      final distance = delta.distance;
      gazeOffset = distance > 0.01 ? delta / distance : Offset.zero;
    }

    _visual.value = PakVisual(
      position: position,
      mood: speed > 40 ? PakMood.fast : pak.currentMood,
      facing: scrollProgress.direction >= 0 ? 1 : -1,
      accent: accent,
      encrypted: pak.encrypted,
      carrying: pak.carrying,
      time: elapsed.inMicroseconds / 1000000.0,
      gazeOffset: gazeOffset,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _visual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pakSize = AppBreakpoints.isMobile(width) ? AppLayout.mobilePakSize : 56.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        _path = RequestPath.build(gutterWidth: constraints.maxWidth, direction: direction);
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: PakPainter(visual: _visual, size: pakSize),
          ),
        );
      },
    );
  }
}
