import 'package:flutter/material.dart';
import '../../core/tokens.dart';

/// 2 concentric rings + center dot + a floating label, playing once over
/// [Motion.ping] then left to [EffectsController] to remove.
class PingEffect extends StatefulWidget {
  final Offset position;
  final String label;
  const PingEffect({super.key, required this.position, required this.label});

  @override
  State<PingEffect> createState() => _PingEffectState();
}

class _PingEffectState extends State<PingEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Motion.ping)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const boxSize = 120.0;
    return Positioned(
      left: widget.position.dx - boxSize / 2,
      top: widget.position.dy - boxSize / 2,
      width: boxSize,
      height: boxSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Motion.out.transform(_controller.value);
          return Opacity(
            opacity: 1 - t,
            child: CustomPaint(
              painter: _PingPainter(t: t),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, -28 * t),
                  child: Text(
                    widget.label,
                    textDirection: TextDirection.ltr,
                    style: AppType.monoLabel.copyWith(color: AppColors.netCyan),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PingPainter extends CustomPainter {
  final double t;
  _PingPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final alpha = (1 - t).clamp(0.0, 1.0);
    canvas.drawCircle(
      center,
      8 + t * 26,
      Paint()
        ..color = AppColors.netCyan.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center,
      4 + t * 14,
      Paint()
        ..color = AppColors.netCyan.withValues(alpha: alpha * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, 3, Paint()..color = AppColors.netCyan.withValues(alpha: alpha));
  }

  @override
  bool shouldRepaint(covariant _PingPainter oldDelegate) => oldDelegate.t != t;
}
