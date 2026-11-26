import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import '../interaction/effects_controller.dart';
import '../interaction/toast_controller.dart';
import '../scene/pak/pak_state.dart';

enum IdleLevel { active, heartbeat, timeout }

/// Tracks user activity (pointer, scroll, key — registered by callers via
/// [registerActivity]) and raises [IdleLevel] after 15s (heartbeat,
/// repeating) and 45s (timeout) of inactivity. Pauses both timers while
/// the tab is hidden (`visibilitychange`) so a backgrounded tab doesn't
/// "time out" instantly the moment it's refocused.
class IdleController extends ChangeNotifier {
  IdleLevel _level = IdleLevel.active;
  IdleLevel get level => _level;

  Timer? _heartbeatTimer;
  Timer? _timeoutTimer;
  StreamSubscription<web.Event>? _visibilitySub;
  bool _started = false;

  static const _heartbeatEvery = Duration(seconds: 15);
  static const _timeoutAfter = Duration(seconds: 45);

  void start() {
    if (_started) return;
    _started = true;
    _armTimers();
    _visibilitySub = web.document.onVisibilityChange.listen((_) {
      if (web.document.hidden) {
        _heartbeatTimer?.cancel();
        _timeoutTimer?.cancel();
      } else {
        _armTimers();
      }
    });
  }

  void registerActivity() {
    if (web.document.hidden) return;
    if (_level != IdleLevel.active) _setLevel(IdleLevel.active);
    _armTimers();
  }

  void _armTimers() {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatEvery, (_) {
      if (_level == IdleLevel.active) _setLevel(IdleLevel.heartbeat);
      if (_level != IdleLevel.timeout) notifyListeners(); // re-pulse even while already idle
    });
    _timeoutTimer = Timer(_timeoutAfter, () => _setLevel(IdleLevel.timeout));
  }

  void _setLevel(IdleLevel level) {
    if (_level == level) return;
    _level = level;
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    _visibilitySub?.cancel();
    super.dispose();
  }
}

/// Reacts to [IdleController] transitions: a ping at Pak's last-known
/// position on each heartbeat, a `408` toast + Pak sleeping on timeout,
/// and a "re-established" toast + Pak startled on the first activity
/// after a timeout. Pure reaction — no layout, so it renders nothing.
class IdleWatcher extends StatefulWidget {
  final Widget child;
  const IdleWatcher({super.key, required this.child});

  @override
  State<IdleWatcher> createState() => _IdleWatcherState();
}

class _IdleWatcherState extends State<IdleWatcher> {
  IdleLevel _lastLevel = IdleLevel.active;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<IdleController>().start();
  }

  void _onIdleChanged(IdleController idle) {
    if (idle.level == _lastLevel) return;
    final previous = _lastLevel;
    _lastLevel = idle.level;
    final pak = context.read<PakController>();
    switch (idle.level) {
      case IdleLevel.heartbeat:
        context.read<EffectsController>().addPing(const Offset(80, 80));
      case IdleLevel.timeout:
        pak.setBase(PakMood.sleeping);
        context.read<ToastController>().show('408 Request Timeout', isError: false);
      case IdleLevel.active:
        if (previous == IdleLevel.timeout) {
          pak.setBase(PakMood.idle);
          pak.react(PakMood.startled, duration: const Duration(milliseconds: 450));
          context.read<ToastController>().show('Connection re-established', isError: false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final idle = context.watch<IdleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onIdleChanged(idle));

    return AnimatedOpacity(
      opacity: idle.level == IdleLevel.timeout ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 600),
      child: widget.child,
    );
  }
}
