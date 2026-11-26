import 'package:flutter/material.dart';
import '../../core/tokens.dart';

/// A floating status-code badge, used by [NetButton] results and the 429
/// rate-limit response. Rises and fades over [Motion.badgeFloat].
class StatusBadgeEffect extends StatelessWidget {
  final Offset position;
  final int statusCode;
  final String label;
  final bool isError;

  const StatusBadgeEffect({
    super.key,
    required this.position,
    required this.statusCode,
    required this.label,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return _FloatingBadge(position: position, statusCode: statusCode, label: label, isError: isError);
  }
}

class _FloatingBadge extends StatefulWidget {
  final Offset position;
  final int statusCode;
  final String label;
  final bool isError;
  const _FloatingBadge({required this.position, required this.statusCode, required this.label, required this.isError});

  @override
  State<_FloatingBadge> createState() => _FloatingBadgeState();
}

class _FloatingBadgeState extends State<_FloatingBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Motion.badgeFloat)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? AppColors.errRed : AppColors.okGreen;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Motion.out.transform(_controller.value);
        return Positioned(
          left: widget.position.dx - 60,
          top: widget.position.dy - 16 - 32 * t,
          width: 120,
          child: Opacity(
            opacity: 1 - t,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '${widget.statusCode} ${widget.label}',
                  textDirection: TextDirection.ltr,
                  style: AppType.monoLabel.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
