import 'dart:async';
import 'package:flutter/material.dart';
import '../navigation/section_registry.dart';
import 'layers.dart';

/// The single shared scroll state every scroll-coupled visual (background,
/// request path, Pak, section reveal) reads from. Owns no ScrollController
/// itself — [PageShell] (the one place that owns the page's ScrollController)
/// calls [attach]/[detach] on mount/unmount, matching the PRD's "one
/// ScrollController owns the page" rule without forcing every provider to
/// be re-created per page.
class ScrollProgress extends ChangeNotifier {
  ScrollController? _controller;

  double _progress = 0;
  double _offsetPx = 0;
  double _velocity = 0;
  int _direction = 0;
  NetLayer _activeLayer = NetLayer.browser;
  SectionId _activeSection = SectionId.browserHero;
  final Set<SectionId> _revealed = {};
  bool _ended = false;
  double? _roundTripMs;

  double get progress => _progress;
  double get offsetPx => _offsetPx;
  double get velocity => _velocity;
  int get direction => _direction;
  NetLayer get activeLayer => _activeLayer;
  SectionId get activeSection => _activeSection;
  Set<SectionId> get revealed => _revealed;

  /// True once the teardown sequence (end of page) has fired and frozen
  /// the latency counter; cleared by [PageShell]'s re-arm logic when the
  /// user scrolls back up past the threshold.
  bool get ended => _ended;
  double? get roundTripMs => _roundTripMs;

  void setEnded(bool value) {
    if (_ended == value) return;
    _ended = value;
    if (value) _roundTripMs = 12 + _progress * 1368;
    notifyListeners();
  }

  // --- EOF overscroll marker (PRD section 12) ---
  double _pull = 0;
  double _pullVelocity = 0;
  Timer? _pullDecayTimer;
  Timer? _pullSpring;

  static const _pullSpringStiffness = 300.0;
  static const _pullSpringDamping = 20.0;
  static const _pullSpringMass = 1.0;
  static const _pullSpringTick = Duration(milliseconds: 16);

  double get pull => _pull;

  /// Called on overscroll-past-bottom (touch/trackpad `OverscrollNotification`
  /// or a clamped mouse-wheel `PointerScrollEvent`). Re-arms the 150ms
  /// no-new-pull timer that triggers the spring-back.
  void addPull(double delta) {
    _pullSpring?.cancel();
    _pullVelocity = 0;
    _pull = (_pull + delta).clamp(0.0, 1.0);
    _scheduleNotify();
    _pullDecayTimer?.cancel();
    _pullDecayTimer = Timer(const Duration(milliseconds: 150), _startPullSpringBack);
  }

  void _startPullSpringBack() {
    _pullSpring?.cancel();
    _pullSpring = Timer.periodic(_pullSpringTick, (timer) {
      const dt = 0.016;
      final force = -_pullSpringStiffness * _pull - _pullSpringDamping * _pullVelocity;
      _pullVelocity += (force / _pullSpringMass) * dt;
      _pull += _pullVelocity * dt;
      if (_pull.abs() < 0.001 && _pullVelocity.abs() < 0.001) {
        _pull = 0;
        _pullVelocity = 0;
        timer.cancel();
      }
      _scheduleNotify();
    });
  }

  double? _lastOffset;
  int? _lastTimeMs;
  Timer? _decayTimer;
  bool _notifyScheduled = false;

  static const _velocityEmaAlpha = 0.2;
  static const _decayDelay = Duration(milliseconds: 120);
  static const _activeLayerLookahead = 0.4; // fraction of viewport height

  void attach(ScrollController controller) {
    _controller = controller;
    controller.addListener(_onScroll);
    _onScroll();
  }

  void detach(ScrollController controller) {
    if (_controller == controller) {
      controller.removeListener(_onScroll);
      _controller = null;
    }
    _decayTimer?.cancel();
  }

  /// Re-reads scroll position against freshly-measured [SectionRegistry]
  /// offsets — called by [PageShell] right after every [SectionRegistry.measure]
  /// pass, since measuring doesn't itself notify anything.
  void refresh() => _onScroll();

  void _onScroll() {
    final controller = _controller;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    final offset = position.pixels;
    final maxScroll = position.maxScrollExtent;
    _progress = maxScroll > 0 ? (offset / maxScroll).clamp(0.0, 1.0).toDouble() : 0.0;
    _offsetPx = offset;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (_lastOffset != null && _lastTimeMs != null && nowMs > _lastTimeMs!) {
      final dt = (nowMs - _lastTimeMs!) / 1000.0;
      final instantVelocity = (offset - _lastOffset!) / dt;
      _velocity = _velocity * (1 - _velocityEmaAlpha) + instantVelocity * _velocityEmaAlpha;
      if (instantVelocity.abs() > 0.5) {
        _direction = instantVelocity > 0 ? 1 : -1;
      }
    }
    _lastOffset = offset;
    _lastTimeMs = nowMs;

    final threshold = offset + position.viewportDimension * _activeLayerLookahead;
    SectionId active = SectionId.browserHero;
    for (final id in SectionId.values) {
      if (SectionRegistry.offsetFor(id) <= threshold) {
        active = id;
        _revealed.add(id);
      } else {
        break;
      }
    }
    _activeLayer = NetLayers.layerFor(active);
    _activeSection = active;

    _decayTimer?.cancel();
    _decayTimer = Timer(_decayDelay, () {
      _velocity = 0;
      _direction = 0;
      _scheduleNotify();
    });

    _scheduleNotify();
  }

  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    _pullDecayTimer?.cancel();
    _pullSpring?.cancel();
    super.dispose();
  }
}
