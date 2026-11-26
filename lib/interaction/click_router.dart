import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../scene/pak/pak_state.dart';
import 'effects_controller.dart';
import 'handled_pointers.dart';
import 'rate_limiter.dart';
import 'toast_controller.dart';

/// Root empty-click detector: a translucent [Listener] over the whole
/// scrollable scene. On `pointerUp`, if the pointer wasn't already claimed
/// by an [Interactive]/NetButton, moved less than 8px, and was held less
/// than 300ms, it's a genuine "empty click" on blank canvas — spawns a
/// ping (or, past the rate limit, a mock 429).
class ClickRouter extends StatefulWidget {
  final Widget child;
  const ClickRouter({super.key, required this.child});

  @override
  State<ClickRouter> createState() => _ClickRouterState();
}

class _ClickRouterState extends State<ClickRouter> {
  final Map<int, Offset> _downPositions = {};
  final Map<int, int> _downTimesMs = {};

  static const _moveThreshold = 8.0;
  static const _holdThreshold = Duration(milliseconds: 300);

  bool _isPrimary(PointerEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return event.buttons == kPrimaryButton || event.buttons == 0;
    return event.kind == PointerDeviceKind.touch;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_isPrimary(event)) return;
    _downPositions[event.pointer] = event.position;
    _downTimesMs[event.pointer] = DateTime.now().millisecondsSinceEpoch;
  }

  void _onPointerUp(PointerUpEvent event) {
    final downPos = _downPositions.remove(event.pointer);
    final downTimeMs = _downTimesMs.remove(event.pointer);
    final handled = context.read<HandledPointers>();
    final wasHandled = handled.contains(event.pointer);
    handled.remove(event.pointer);
    if (wasHandled || downPos == null || downTimeMs == null) return;

    final moved = (event.position - downPos).distance;
    final heldMs = DateTime.now().millisecondsSinceEpoch - downTimeMs;
    if (moved < _moveThreshold && heldMs < _holdThreshold.inMilliseconds) {
      _emptyClick(event.position);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _downPositions.remove(event.pointer);
    _downTimesMs.remove(event.pointer);
    context.read<HandledPointers>().remove(event.pointer);
  }

  void _emptyClick(Offset globalPosition) {
    final pak = context.read<PakController>();
    final effects = context.read<EffectsController>();
    pak.react(PakMood.lookingAt, at: globalPosition);

    final allowed = context.read<RateLimiter>().registerClick();
    if (!allowed) {
      effects.addBadge(globalPosition, statusCode: 429, label: 'Too Many Requests', isError: true);
      pak.react(PakMood.dizzy, at: globalPosition, duration: const Duration(milliseconds: 1600));
      context.read<ToastController>().show('429 Too Many Requests — slow down a little', isError: true);
      return;
    }
    effects.addPing(globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}
