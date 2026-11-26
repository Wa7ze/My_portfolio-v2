import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/tokens.dart';
import '../scroll/layers.dart';
import '../scroll/scroll_progress.dart';

/// The fixed (non-scrolling) backdrop: base background color, a radial
/// gradient tinted by the active layer's accent at 8%, cross-fading on
/// layer change, plus an ambient grid with a 0.3x scroll parallax. Has a
/// functioning light variant from the start (the kept theme toggle).
class BackgroundLayer extends StatefulWidget {
  const BackgroundLayer({super.key});

  @override
  State<BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _blend;
  NetLayer? _lastLayer;

  @override
  void initState() {
    super.initState();
    _blend = AnimationController(vsync: this, duration: Motion.layerBlend, value: 1);
  }

  @override
  void dispose() {
    _blend.dispose();
    super.dispose();
  }

  void _maybeBlend(NetLayer layer) {
    if (_lastLayer != null && _lastLayer != layer) {
      _blend.forward(from: 0);
    }
    _lastLayer = layer;
  }

  @override
  Widget build(BuildContext context) {
    final scrollProgress = context.watch<ScrollProgress>();
    final palette = AppPalette.of(context);
    _maybeBlend(scrollProgress.activeLayer);
    final accent = NetLayers.accentFor(scrollProgress.activeLayer);

    return AnimatedBuilder(
      animation: _blend,
      builder: (context, _) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _BackgroundPainter(
            bg: palette.bg,
            line: palette.line,
            accent: accent,
            blend: Motion.out.transform(_blend.value),
            parallaxOffset: scrollProgress.offsetPx * 0.3,
          ),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Color bg;
  final Color line;
  final Color accent;
  final double blend;
  final double parallaxOffset;
  static const double _gridSpacing = 32.0;

  _BackgroundPainter({
    required this.bg,
    required this.line,
    required this.accent,
    required this.blend,
    required this.parallaxOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    final center = size.center(Offset.zero);
    final radius = size.longestSide * 0.75;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.08 * blend), accent.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final gridPaint = Paint()
      ..color = line.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final yOffset = parallaxOffset % _gridSpacing;
    for (double y = -yOffset; y < size.height; y += _gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += _gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.bg != bg ||
      oldDelegate.accent != accent ||
      oldDelegate.blend != blend ||
      oldDelegate.parallaxOffset != parallaxOffset;
}
