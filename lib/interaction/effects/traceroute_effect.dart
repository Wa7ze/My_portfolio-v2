import 'package:flutter/material.dart';
import '../../core/tokens.dart';
import '../../scene/request_path.dart';

/// Highlights a length range along the request path with a glowing sweep
/// — used by nav `goTo` (phase 4) to show the route taken. Built now per
/// the phase-3 plan; exercised fully once phase 4's nav calls it.
class TracerouteEffect extends StatefulWidget {
  final double fromLength;
  final double toLength;
  const TracerouteEffect({super.key, required this.fromLength, required this.toLength});

  @override
  State<TracerouteEffect> createState() => _TracerouteEffectState();
}

class _TracerouteEffectState extends State<TracerouteEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Motion.traceDraw)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final path = RequestPath.build(gutterWidth: constraints.maxWidth, direction: direction);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _TraceroutePainter(
              path: path,
              from: widget.fromLength,
              to: widget.toLength,
              t: Motion.out.transform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _TraceroutePainter extends CustomPainter {
  final RequestPath path;
  final double from;
  final double to;
  final double t;

  _TraceroutePainter({required this.path, required this.from, required this.to, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final metric = path.metric;
    if (metric == null) return;
    final total = metric.length;
    final start = from.clamp(0.0, total);
    final end = (from + (to - from) * t).clamp(0.0, total);
    if (end <= start) return;
    final segment = metric.extractPath(start, end);
    canvas.drawPath(
      segment,
      Paint()
        ..color = AppColors.okGreen.withValues(alpha: AppColors.glowOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, AppColors.glowBlurSigma),
    );
    canvas.drawPath(
      segment,
      Paint()
        ..color = AppColors.okGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _TraceroutePainter oldDelegate) => oldDelegate.t != t;
}
