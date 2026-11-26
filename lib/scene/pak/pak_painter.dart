import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import '../../core/tokens.dart';
import 'pak_state.dart';

/// Pak's fully-computed per-frame visual state. Built once per tick by
/// [PakWidget]'s ticker and pushed into a [ValueNotifier] that the
/// [PakPainter] uses as its sole repaint trigger — the painter itself never
/// drives its own repaints.
class PakVisual {
  final Offset position;
  final PakMood mood;
  final int facing; // 1 = forward/right, -1 = backward/left
  final Color accent;
  final bool encrypted;
  final bool carrying;

  const PakVisual({
    required this.position,
    required this.mood,
    required this.facing,
    required this.accent,
    this.encrypted = false,
    this.carrying = false,
  });
}

/// Draw order: glow -> trails -> backpack -> body -> header cap -> shell
/// (if encrypted) -> eyes -> extras. Phases 0-4 give bespoke treatment to
/// idle/traveling/fast/sleeping; other moods fall back to idle (see
/// PakMood doc).
class PakPainter extends CustomPainter {
  final ValueNotifier<PakVisual> visual;
  final double size_; // body width, scaled per breakpoint

  PakPainter({required this.visual, required double size})
      : size_ = size,
        super(repaint: visual);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final v = visual.value;
    final w = size_;
    final h = size_ * 0.78;
    final center = v.position;
    final bodyRect = Rect.fromCenter(center: center, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.2));

    final squash = v.mood == PakMood.fast ? 0.82 : 1.0;
    final stretch = v.mood == PakMood.fast ? 1.18 : 1.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(stretch, squash);
    canvas.translate(-center.dx, -center.dy);

    // Glow.
    canvas.drawRRect(
      rrect.inflate(6),
      Paint()
        ..color = v.accent.withValues(alpha: AppColors.glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, AppColors.glowBlurSigma),
    );

    // Backpack (carrying).
    if (v.carrying) {
      final backRect = Rect.fromCenter(center: center.translate(-w * 0.55 * v.facing, 2), width: w * 0.28, height: h * 0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(backRect, Radius.circular(4)),
        Paint()..color = v.accent.withValues(alpha: 0.9),
      );
    }

    // Body.
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF111729));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = v.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Header cap.
    final capRect = Rect.fromLTWH(bodyRect.left + w * 0.12, bodyRect.top, w * 0.76, h * 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, Radius.circular(w * 0.1)),
      Paint()..color = v.accent.withValues(alpha: 0.35),
    );

    // Encrypted shell (dashed outer ring).
    if (v.encrypted) {
      final ringRect = bodyRect.inflate(5);
      final ringPath = Path()..addRRect(RRect.fromRectAndRadius(ringRect, Radius.circular(w * 0.24)));
      for (final metric in ringPath.computeMetrics()) {
        double d = 0;
        while (d < metric.length) {
          final next = (d + 4).clamp(0.0, metric.length);
          canvas.drawPath(
            metric.extractPath(d, next),
            Paint()
              ..color = v.accent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
          d += 8;
        }
      }
    }

    // Eyes.
    final eyeY = center.dy - h * 0.05;
    final eyeDx = w * 0.16;
    final eyeRadius = w * 0.07;
    final sleeping = v.mood == PakMood.sleeping;
    for (final side in [-1, 1]) {
      final eyeCenter = Offset(center.dx + eyeDx * side, eyeY);
      if (sleeping) {
        canvas.drawLine(
          eyeCenter.translate(-eyeRadius, 0),
          eyeCenter.translate(eyeRadius, 0),
          Paint()
            ..color = const Color(0xFFE6EAF2)
            ..strokeWidth = 2,
        );
      } else {
        canvas.drawCircle(eyeCenter, eyeRadius, Paint()..color = const Color(0xFFE6EAF2));
        final gazeShift = Offset(v.facing * eyeRadius * 0.3, 0);
        canvas.drawCircle(eyeCenter + gazeShift, eyeRadius * 0.45, Paint()..color = const Color(0xFF0A0E1A));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PakPainter oldDelegate) => false;
}
