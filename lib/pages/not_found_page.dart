import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/tokens.dart';
import '../interaction/net_button.dart';
import '../router.dart';
import '../scene/pak/pak_painter.dart';
import '../scene/pak/pak_state.dart';

/// 404. PRD section 13: centered Pak in `lost` mood (question mark, eyes
/// sweeping left/right), the real unmatched path in the `GET ... → no
/// route to host` line, and one `NetButton` back home.
class NotFoundPage extends StatefulWidget {
  final String requestedPath;
  const NotFoundPage({super.key, required this.requestedPath});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ValueNotifier<PakVisual> _visual;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _visual = ValueNotifier(
      const PakVisual(position: Offset.zero, mood: PakMood.lost, facing: 1, accent: AppColors.errRed),
    );
    _ticker = createTicker((elapsed) {
      _elapsed = elapsed;
      _visual.value = PakVisual(
        position: _visual.value.position,
        mood: PakMood.lost,
        facing: 1,
        accent: AppColors.errRed,
        time: _elapsed.inMicroseconds / 1000000.0,
      );
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _visual.dispose();
    super.dispose();
  }

  Future<NetResult> _goHome(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (context.mounted) router.go('/');
    return const NetResult.success();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 96,
              height: 80,
              child: CustomPaint(
                painter: _LostPakPainter(visual: _visual),
              ),
            ),
            const SizedBox(height: AppSpacing.s32),
            Text('404', style: AppType.display.copyWith(color: palette.textPrimary)),
            const SizedBox(height: AppSpacing.s16),
            Text('Packet lost in transit.', style: AppType.body.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'GET ${widget.requestedPath} → no route to host',
              textDirection: TextDirection.ltr,
              style: AppType.mono.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.s32),
            NetButton(label: 'GET /', onRequest: () => _goHome(context)),
          ],
        ),
      ),
    );
  }
}

class _LostPakPainter extends CustomPainter {
  final ValueNotifier<PakVisual> visual;
  _LostPakPainter({required this.visual}) : super(repaint: visual);

  @override
  void paint(Canvas canvas, Size size) {
    final centered = PakVisual(
      position: size.center(Offset(0, 8)),
      mood: visual.value.mood,
      facing: visual.value.facing,
      accent: visual.value.accent,
      time: visual.value.time,
    );
    PakPainter(visual: ValueNotifier(centered), size: 56).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _LostPakPainter oldDelegate) => true;
}
