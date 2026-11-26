import 'package:flutter/material.dart';

/// Pak's full mood vocabulary. Phases 0-4 give distinct visual treatment to
/// idle/traveling/fast/sleeping/encrypted/carrying; the rest render as idle
/// for now and get their bespoke look wired up alongside the interactions
/// that trigger them (phase 3+: throttled on rate-limit, lookingAt on
/// clicks, startled/dizzy on errors, waving/bowing/lost on nav/404).
enum PakMood {
  idle,
  traveling,
  fast,
  encrypted,
  carrying,
  lookingAt,
  throttled,
  dizzy,
  sleeping,
  startled,
  waving,
  bowing,
  lost,
}

/// Pak's discrete (non-per-frame) state: a persistent base mood plus a
/// timed one-shot reaction that overrides it. Read directly by
/// [PakWidget]'s ticker each frame — this is a [ChangeNotifier] only so
/// interaction code (phase 3+) can trigger reactions; it is never watched
/// for rebuilds on the animation hot path.
class PakController extends ChangeNotifier {
  PakMood _baseMood = PakMood.idle;
  PakMood? _oneShot;
  DateTime? _oneShotUntil;
  Offset? _gazeTarget;
  bool _encrypted = false;
  bool _carrying = false;

  PakMood get baseMood => _baseMood;
  Offset? get gazeTarget => _gazeTarget;
  bool get encrypted => _encrypted;
  bool get carrying => _carrying;

  PakMood get currentMood {
    final until = _oneShotUntil;
    if (_oneShot != null && until != null && DateTime.now().isBefore(until)) {
      return _oneShot!;
    }
    return _baseMood;
  }

  void setBase(PakMood mood) {
    if (_baseMood == mood) return;
    _baseMood = mood;
    notifyListeners();
  }

  void react(PakMood mood, {Offset? at, Duration duration = const Duration(milliseconds: 900)}) {
    _oneShot = mood;
    _oneShotUntil = DateTime.now().add(duration);
    if (at != null) _gazeTarget = at;
    notifyListeners();
    Future.delayed(duration, () {
      final until = _oneShotUntil;
      if (until != null && !DateTime.now().isBefore(until)) {
        _oneShot = null;
        notifyListeners();
      }
    });
  }

  void setEncrypted(bool value) {
    if (_encrypted == value) return;
    _encrypted = value;
    notifyListeners();
  }

  void setCarrying(bool value) {
    if (_carrying == value) return;
    _carrying = value;
    notifyListeners();
  }

  void setGazeTarget(Offset? target) {
    _gazeTarget = target;
    notifyListeners();
  }
}
