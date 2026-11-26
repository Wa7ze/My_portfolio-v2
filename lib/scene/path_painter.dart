import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/reduced_motion.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';
import '../scroll/layers.dart';
import '../scroll/scroll_progress.dart';
import 'request_path.dart';

/// Draws the request path within the section gutter: an untraveled dashed
/// line for the full extent, a solid traveled portion colored by the
/// active layer with a glow pass, a ring at each station (filled once
/// reached), and 3 looping packet dots along the traveled portion.
class PathLayer extends StatefulWidget {
  const PathLayer({super.key});

  @override
  State<PathLayer> createState() => _PathLayerState();
}

class _PathLayerState extends State<PathLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  bool _loopStarted = false;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  // MediaQuery (via MotionPrefs) can't be read in initState — only once
  // dependencies are available, hence starting the loop here instead.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loopStarted && !MotionPrefs.of(context).reduced) {
      _loopStarted = true;
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollProgress = context.watch<ScrollProgress>();
    final direction = Directionality.of(context);
    final reduced = MotionPrefs.of(context).reduced;
    final palette = AppPalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final requestPath = RequestPath.build(
          gutterWidth: constraints.maxWidth,
          direction: direction,
        );
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loop,
            builder:
                (context, _) => CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: PathPainter(
                    requestPath: requestPath,
                    progress: scrollProgress.progress,
                    activeLayer: scrollProgress.activeLayer,
                    revealed: scrollProgress.revealed,
                    loopT: reduced ? 0 : _loop.value,
                    lineColor: palette.line,
                    showLoopingDots: !reduced,
                  ),
                ),
          ),
        );
      },
    );
  }
}

class PathPainter extends CustomPainter {
  final RequestPath requestPath;
  final double progress;
  final NetLayer activeLayer;
  final Set<SectionId> revealed;
  final double loopT;
  final Color lineColor;
  final bool showLoopingDots;

  PathPainter({
    required this.requestPath,
    required this.progress,
    required this.activeLayer,
    required this.revealed,
    required this.loopT,
    required this.lineColor,
    required this.showLoopingDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (requestPath.metric == null) return;
    final accent = NetLayers.accentFor(activeLayer);
    final traveledLength = progress * requestPath.totalLength;

    // Untraveled: dashed full path.
    final dashed = _dashPath(requestPath.path, dashLength: 6, gapLength: 6);
    canvas.drawPath(
      dashed,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Traveled: solid, glowing, accent-colored.
    final traveled = requestPath.metric!.extractPath(
      0,
      traveledLength.clamp(0.0, requestPath.totalLength).toDouble(),
    );
    canvas.drawPath(
      traveled,
      Paint()
        ..color = accent.withValues(alpha: AppColors.glowOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          AppColors.glowBlurSigma,
        ),
    );
    canvas.drawPath(
      traveled,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Stations.
    for (final id in SectionId.values) {
      final station = requestPath.stations[id.index];
      final reached = revealed.contains(id);
      canvas.drawCircle(
        station,
        reached ? 6 : 4,
        Paint()
          ..color =
              reached ? NetLayers.accentFor(NetLayers.layerFor(id)) : lineColor
          ..style = reached ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Looping packet dots along the traveled portion.
    if (showLoopingDots && traveledLength > 0) {
      for (int i = 0; i < 3; i++) {
        final t = (loopT + i / 3) % 1.0;
        final dotPos = requestPath.positionAtLength(t * traveledLength);
        canvas.drawCircle(
          dotPos,
          3,
          Paint()..color = accent.withValues(alpha: 0.8),
        );
      }
    }
  }

  Path _dashPath(
    Path source, {
    required double dashLength,
    required double gapLength,
  }) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dashLength : gapLength);
        if (draw) {
          dashed.addPath(
            metric.extractPath(
              distance,
              next.clamp(0.0, metric.length).toDouble(),
            ),
            Offset.zero,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.activeLayer != activeLayer ||
      oldDelegate.loopT != loopT ||
      oldDelegate.revealed.length != revealed.length;
}
