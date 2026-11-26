import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/tokens.dart';
import '../scroll/scroll_progress.dart';

/// Fixed latency readout, pinned top-trailing (direction-aware, not a
/// hardcoded `top: right`) so it mirrors correctly in RTL. Odometer-roll
/// digit animation is an optional stretch, not built here.
class LatencyCounter extends StatelessWidget {
  const LatencyCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final scroll = context.watch<ScrollProgress>();
    final palette = AppPalette.of(context);
    final ended = scroll.ended;
    final ms = (12 + scroll.progress * 1368).round();

    final label = ended
        ? 'Round trip: ${((scroll.roundTripMs ?? ms) / 1000).toStringAsFixed(2)}s'
        : '${ms}ms';
    final color = ended ? AppColors.okGreen : palette.textMuted;

    return Positioned.fill(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(top: AppSpacing.s16, end: AppSpacing.s16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
            decoration: BoxDecoration(
              color: palette.bgRaised.withValues(alpha: 0.8),
              border: Border.all(color: ended ? AppColors.okGreen : palette.line),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              label,
              textDirection: TextDirection.ltr,
              style: AppType.mono.copyWith(color: color),
            ),
          ),
        ),
      ),
    );
  }
}
