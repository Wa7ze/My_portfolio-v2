import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import '../core/tokens.dart';

class PingEntry {
  final Object id;
  final Offset globalPosition;
  final String label;
  const PingEntry({required this.id, required this.globalPosition, required this.label});
}

class BadgeEntry {
  final Object id;
  final Offset globalPosition;
  final int statusCode;
  final String label;
  final bool isError;
  const BadgeEntry({
    required this.id,
    required this.globalPosition,
    required this.statusCode,
    required this.label,
    required this.isError,
  });
}

class TracerouteEntry {
  final double fromLength;
  final double toLength;
  const TracerouteEntry({required this.fromLength, required this.toLength});
}

class RedirectEntry {
  final Object id;
  final Offset globalPosition;
  final String label;
  const RedirectEntry({required this.id, required this.globalPosition, required this.label});
}

/// Holds every transient interaction effect (pings, status badges, the
/// traceroute highlight), auto-expiring each after its lifetime. Capped at
/// 6 pings / 4 badges / 1 traceroute alive at once — oldest evicted.
class EffectsController extends ChangeNotifier {
  final List<PingEntry> _pings = [];
  final List<BadgeEntry> _badges = [];
  final List<RedirectEntry> _redirects = [];
  TracerouteEntry? _traceroute;

  static const maxPings = 6;
  static const maxBadges = 4;
  static const maxRedirects = 2;
  static const _extraLifetime = Duration(milliseconds: 200);
  static const _redirectLifetime = Duration(milliseconds: 900);

  List<PingEntry> get pings => List.unmodifiable(_pings);
  List<BadgeEntry> get badges => List.unmodifiable(_badges);
  List<RedirectEntry> get redirects => List.unmodifiable(_redirects);
  TracerouteEntry? get traceroute => _traceroute;

  static final _pingLabelWeights = <MapEntry<String, double>>[
    MapEntry('ping ${20 + Random().nextInt(60)}ms', 0.5),
    const MapEntry('ICMP echo reply', 0.25),
    const MapEntry('TTL=64', 0.15),
    const MapEntry('404: nothing here', 0.10),
  ];

  static String _pickPingLabel() {
    final r = Random().nextDouble();
    double cumulative = 0;
    for (final entry in _pingLabelWeights) {
      cumulative += entry.value;
      if (r <= cumulative) return entry.key;
    }
    return _pingLabelWeights.last.key;
  }

  void addPing(Offset globalPosition) {
    final entry = PingEntry(id: UniqueKey(), globalPosition: globalPosition, label: _pickPingLabel());
    _pings.add(entry);
    if (_pings.length > maxPings) _pings.removeAt(0);
    notifyListeners();
    Future.delayed(Motion.ping + _extraLifetime, () {
      if (_pings.remove(entry)) notifyListeners();
    });
  }

  void addBadge(Offset globalPosition, {required int statusCode, required String label, required bool isError}) {
    final entry = BadgeEntry(
      id: UniqueKey(),
      globalPosition: globalPosition,
      statusCode: statusCode,
      label: label,
      isError: isError,
    );
    _badges.add(entry);
    if (_badges.length > maxBadges) _badges.removeAt(0);
    notifyListeners();
    Future.delayed(Motion.badgeFloat + _extraLifetime, () {
      if (_badges.remove(entry)) notifyListeners();
    });
  }

  void addRedirect(Offset globalPosition, {required String label}) {
    final entry = RedirectEntry(id: UniqueKey(), globalPosition: globalPosition, label: label);
    _redirects.add(entry);
    if (_redirects.length > maxRedirects) _redirects.removeAt(0);
    notifyListeners();
    Future.delayed(_redirectLifetime + _extraLifetime, () {
      if (_redirects.remove(entry)) notifyListeners();
    });
  }

  void setTraceroute(double fromLength, double toLength) {
    _traceroute = TracerouteEntry(fromLength: fromLength, toLength: toLength);
    notifyListeners();
    Future.delayed(Motion.traceDraw + _extraLifetime, () {
      _traceroute = null;
      notifyListeners();
    });
  }
}
