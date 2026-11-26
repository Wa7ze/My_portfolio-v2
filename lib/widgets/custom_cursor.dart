import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/reduced_motion.dart';
import '../core/tokens.dart';

/// Tracks whether the pointer is currently over an [Interactive] (or
/// NetButton/NetLink) widget, so [CustomCursor] can grow its "open port"
/// ring. A simple enter/exit counter rather than a boolean: nested
/// interactive widgets (rare, but possible) shouldn't cause the ring to
/// shrink early when the inner one's exit fires before the outer one's.
class CursorController extends ChangeNotifier {
  int _depth = 0;
  bool get hovering => _depth > 0;

  void enter() {
    _depth++;
    if (_depth == 1) notifyListeners();
  }

  void exit() {
    if (_depth == 0) return;
    _depth--;
    if (_depth == 0) notifyListeners();
  }
}

class _CursorVisual {
  final Offset? position;
  final List<Offset> trail;
  final bool hovering;
  final bool pressed;
  const _CursorVisual({required this.position, required this.trail, required this.hovering, required this.pressed});
}

/// Desktop-mouse-only custom cursor (PRD section 13): an 8px glowing node
/// that follows the pointer exactly, a fading trail of its last 10
/// positions, and a ring that grows over an [Interactive]. Disabled for
/// the rest of the session the moment a touch/stylus event is seen.
class CustomCursor extends StatefulWidget {
  final CursorController controller;
  final Widget child;
  const CustomCursor({super.key, required this.controller, required this.child});

  @override
  State<CustomCursor> createState() => _CustomCursorState();
}

class _CustomCursorState extends State<CustomCursor> {
  final ValueNotifier<_CursorVisual> _visual = ValueNotifier(
    const _CursorVisual(position: null, trail: [], hovering: false, pressed: false),
  );
  final List<Offset> _trail = [];
  bool _mouseSeen = false;
  bool _disabledForSession = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onHoverChanged);
  }

  @override
  void didUpdateWidget(CustomCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onHoverChanged);
      widget.controller.addListener(_onHoverChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onHoverChanged);
    _visual.dispose();
    super.dispose();
  }

  void _onHoverChanged() => _push(_visual.value.position);

  void _push(Offset? position) {
    _visual.value = _CursorVisual(
      position: position,
      trail: List.of(_trail),
      hovering: widget.controller.hovering,
      pressed: _pressed,
    );
  }

  void _handlePointer(PointerEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      if (!_disabledForSession) {
        setState(() => _disabledForSession = true);
        _push(null);
      }
      return;
    }
    if (_disabledForSession) return;
    if (!_mouseSeen) setState(() => _mouseSeen = true);
    _trail.add(event.position);
    if (_trail.length > 10) _trail.removeAt(0);
    _push(event.position);
  }

  void _handleExit(PointerExitEvent event) {
    _trail.clear();
    _push(null);
  }

  @override
  Widget build(BuildContext context) {
    if (MotionPrefs.of(context).reduced) return widget.child;
    final showCustom = _mouseSeen && !_disabledForSession;
    return MouseRegion(
      cursor: showCustom ? SystemMouseCursors.none : MouseCursor.defer,
      onHover: _handlePointer,
      onExit: _handleExit,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: _handlePointer,
        onPointerDown: (e) {
          _handlePointer(e);
          if (e.kind == PointerDeviceKind.mouse) {
            _pressed = true;
            _push(e.position);
          }
        },
        onPointerUp: (e) {
          _pressed = false;
          _push(e.position);
        },
        child: Stack(
          children: [
            widget.child,
            if (showCustom)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _CursorPainter(_visual)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CursorPainter extends CustomPainter {
  final ValueNotifier<_CursorVisual> visual;
  _CursorPainter(this.visual) : super(repaint: visual);

  @override
  void paint(Canvas canvas, Size size) {
    final v = visual.value;
    final pos = v.position;
    if (pos == null) return;

    // Trail.
    for (var i = 0; i < v.trail.length - 1; i++) {
      final fraction = i / v.trail.length;
      canvas.drawLine(
        v.trail[i],
        v.trail[i + 1],
        Paint()
          ..color = AppColors.netCyan.withValues(alpha: 0.4 * fraction)
          ..strokeWidth = 0.5 + 1.5 * fraction
          ..strokeCap = StrokeCap.round,
      );
    }

    // Hover ring.
    if (v.hovering) {
      canvas.drawCircle(
        pos,
        v.pressed ? 20 : 28,
        Paint()
          ..color = AppColors.netCyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Node + glow.
    canvas.drawCircle(pos, 8, Paint()..color = AppColors.netCyan.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(pos, 4, Paint()..color = AppColors.netCyan);
  }

  @override
  bool shouldRepaint(covariant _CursorPainter oldDelegate) => false;
}
