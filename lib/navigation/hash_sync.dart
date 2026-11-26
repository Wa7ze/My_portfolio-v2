import 'dart:async';
import 'package:web/web.dart' as web;
import 'section_registry.dart';

/// Syncs the active section into the URL as a bare `#about`-style fragment.
///
/// This app uses `usePathUrlStrategy()` (phase 6) — the path itself (`/`)
/// is the only real route go_router matches, and the fragment is purely a
/// cosmetic in-page anchor the browser never sends to the server. That
/// makes this safe to keep simple, unlike the phase 0-4 hash-strategy
/// workaround this replaces (`#/?section=about`), which had to keep the
/// path valid because the fragment WAS the matched path back then.
abstract final class HashSync {
  static const Map<SectionId, String> _sectionNames = {
    SectionId.browserHero: 'home',
    SectionId.networkAbout: 'about',
    SectionId.gatewaySkills: 'skills',
    SectionId.apiProjects: 'projects',
    SectionId.logicApproach: 'approach',
    SectionId.databaseExperience: 'experience',
    SectionId.responseContact: 'contact',
    SectionId.teardownFooter: 'contact',
  };

  static Timer? _debounce;

  static String _nameFor(SectionId id) => _sectionNames[id] ?? 'home';

  static SectionId? sectionForHash(String hash) {
    final name = hash.replaceFirst('#', '');
    if (name.isEmpty) return null;
    for (final entry in _sectionNames.entries) {
      if (entry.value == name) return entry.key;
    }
    return null;
  }

  /// Called right after a `goTo` navigation — always `replaceState`, never
  /// `pushState`, so hash navigation doesn't pollute browser history.
  static void onNavigate(SectionId id) {
    _debounce?.cancel();
    _replaceHash(id);
  }

  /// Called as the active section changes while scrolling — debounced
  /// 300ms so it doesn't fire on every frame.
  static void onScrollActiveSectionChanged(SectionId id) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _replaceHash(id),
    );
  }

  static void _replaceHash(SectionId id) {
    // Deferred a microtask: calling history.replaceState synchronously
    // inside a build/event-dispatch callback can race the Router widget's
    // own restoreState cycle (see docs/AUDIT.md). Deferring avoids it.
    scheduleMicrotask(() {
      web.window.history.replaceState(
        web.window.history.state,
        '',
        '${web.window.location.pathname}#${_nameFor(id)}',
      );
    });
  }

  /// Reads the current `location.hash` on load.
  static SectionId? readInitialSection() =>
      sectionForHash(web.window.location.hash);
}
