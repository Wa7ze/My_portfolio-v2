import 'dart:ui';
import '../navigation/section_registry.dart';

/// A path visiting one "station" per section, connected by cubic Bezier
/// S-curves, built fresh from the current [SectionRegistry] offsets and
/// text direction (mirrored on RTL so the gutter/path sit on the correct
/// side). Cheap to rebuild per repaint — ~8 stations, one contour.
class RequestPath {
  final Path path;
  final PathMetric? metric;
  final List<Offset> stations;
  final List<Offset> _samples; // every 4px along the path, for nearest-point lookups

  RequestPath._(this.path, this.metric, this.stations, this._samples);

  static const double _sampleStep = 4.0;
  static const double _stationYOffset = 40.0;

  factory RequestPath.build({required double gutterWidth, required TextDirection direction}) {
    final stations = <Offset>[];
    for (final id in SectionId.values) {
      final y = SectionRegistry.offsetFor(id) + _stationYOffset;
      final xFrac = id.index.isEven ? 0.35 : 0.65;
      var x = gutterWidth * xFrac;
      if (direction == TextDirection.rtl) x = gutterWidth - x;
      stations.add(Offset(x, y));
    }

    final path = Path();
    if (stations.isNotEmpty) {
      path.moveTo(stations.first.dx, stations.first.dy);
      for (int i = 1; i < stations.length; i++) {
        final prev = stations[i - 1];
        final curr = stations[i];
        final midY = (prev.dy + curr.dy) / 2;
        path.cubicTo(prev.dx, midY, curr.dx, midY, curr.dx, curr.dy);
      }
    }

    final metrics = path.computeMetrics().toList();
    final metric = metrics.isNotEmpty ? metrics.first : null;

    final samples = <Offset>[];
    if (metric != null) {
      for (double d = 0; d <= metric.length; d += _sampleStep) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent != null) samples.add(tangent.position);
      }
    }

    return RequestPath._(path, metric, stations, samples);
  }

  double get totalLength => metric?.length ?? 0;

  Offset positionAtLength(double length) {
    final m = metric;
    if (m == null || m.length == 0) return stations.isNotEmpty ? stations.first : Offset.zero;
    final clamped = length.clamp(0.0, m.length).toDouble();
    return m.getTangentForOffset(clamped)?.position ?? Offset.zero;
  }

  Offset positionAtProgress(double t) => positionAtLength(t.clamp(0.0, 1.0) * totalLength);

  /// Nearest sampled point on the path to [point], for phase-3 "empty
  /// click near the path" effects.
  Offset nearestPoint(Offset point) {
    if (_samples.isEmpty) return point;
    var best = _samples.first;
    var bestDistSq = (best - point).distanceSquared;
    for (final sample in _samples) {
      final distSq = (sample - point).distanceSquared;
      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        best = sample;
      }
    }
    return best;
  }

  /// The path-length position of [id]'s station — used by nav's traceroute
  /// highlight (phase 4), found via the nearest sampled point.
  double lengthForStation(SectionId id) {
    if (_samples.isEmpty) return 0;
    final target = stations[id.index];
    var bestIndex = 0;
    var bestDistSq = (_samples.first - target).distanceSquared;
    for (int i = 1; i < _samples.length; i++) {
      final distSq = (_samples[i] - target).distanceSquared;
      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        bestIndex = i;
      }
    }
    return bestIndex * _sampleStep;
  }
}
