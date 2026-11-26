import 'package:flutter/material.dart';
import '../../core/tokens.dart';

/// Plays on every [NetLink] tap: a status badge ("301 Moved Permanently" or
/// "SMTP 250 OK" for mailto links) pops with [Motion.back], holds, then
/// fades, while a tiny Pak-shaped flyer arcs from the link to the top-right
/// corner of the viewport and shrinks away.
class RedirectEffect extends StatefulWidget {
  final Offset position;
  final String label;

  const RedirectEffect({super.key, required this.position, required this.label});

  @override
  State<RedirectEffect> createState() => _RedirectEffectState();
}

class _RedirectEffectState extends State<RedirectEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _badge;
  late final AnimationController _flyer;

  static const _badgeHold = Duration(milliseconds: 600);
  static const _badgeFade = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _badge = AnimationController(vsync: this, duration: _badgeHold + _badgeFade)..forward();
    _flyer = AnimationController(vsync: this, duration: Motion.redirect + const Duration(milliseconds: 150))..forward();
  }

  @override
  void dispose() {
    _badge.dispose();
    _flyer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final target = Offset(size.width - 28, 28);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _badge,
          builder: (context, _) {
            final appearT = (_badge.value / 0.18).clamp(0.0, 1.0);
            final holdFraction = _badgeHold.inMilliseconds / (_badgeHold + _badgeFade).inMilliseconds;
            final fadeT = _badge.value <= holdFraction ? 0.0 : (_badge.value - holdFraction) / (1 - holdFraction);
            final scale = Motion.back.transform(appearT);
            return Positioned(
              left: widget.position.dx - 70,
              top: widget.position.dy - 36,
              width: 140,
              child: Opacity(
                opacity: 1 - fadeT,
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                      decoration: BoxDecoration(
                        color: AppColors.netCyan.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.netCyan),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        widget.label,
                        textDirection: TextDirection.ltr,
                        style: AppType.monoLabel.copyWith(color: AppColors.netCyan),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _flyer,
          builder: (context, _) {
            final t = Motion.outQuart.transform(_flyer.value);
            // A gentle arc: lift the midpoint above the straight line.
            final lift = -60 * (1 - (2 * t - 1) * (2 * t - 1));
            final pos = Offset.lerp(widget.position, target, t)! + Offset(0, lift);
            final scale = 1 - 0.6 * t;
            return Positioned(
              left: pos.dx - 8,
              top: pos.dy - 7,
              child: Opacity(
                opacity: 1 - t * 0.8,
                child: Transform.scale(
                  scale: scale,
                  child: const _MiniPak(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniPak extends StatelessWidget {
  const _MiniPak();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 12,
      child: CustomPaint(painter: _MiniPakPainter()),
    );
  }
}

class _MiniPakPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawRRect(rrect, Paint()..color = AppColors.netCyan);
    final eyeY = size.height * 0.45;
    for (final dx in [size.width * 0.32, size.width * 0.68]) {
      canvas.drawCircle(Offset(dx, eyeY), 1.3, Paint()..color = const Color(0xFF0A0E1A));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPakPainter oldDelegate) => false;
}
