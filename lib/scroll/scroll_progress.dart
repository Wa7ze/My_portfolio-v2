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

  double get progress => _progress;
  double get offsetPx => _offsetPx;
  double get velocity => _velocity;
  int get direction => _direction;
  NetLayer get activeLayer => _activeLayer;
  SectionId get activeSection => _activeSection;
  Set<SectionId> get revealed => _revealed;

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
    super.dispose();
  }
}
