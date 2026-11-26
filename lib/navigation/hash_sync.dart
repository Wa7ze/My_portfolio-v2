import 'dart:async';
import 'package:web/web.dart' as web;
import 'section_registry.dart';

/// Syncs the active section into the URL — as a `section` query parameter
/// inside the `#/` fragment (`#/?section=about`), never as a bare fragment
/// (`#about`).
///
/// This app uses go_router's *hash* URL strategy (confirmed empirically:
/// `#/bogus` 404s, `#/` loads fine), meaning the content after `#/` is the
/// actual matched *path* — a bare `#about` is parsed as path "about", which
/// has no matching route and renders the 404 page on every load/reload.
/// Keeping the path at `/` (the only real route) and putting the section in
/// a query parameter keeps this purely cosmetic, as intended, without ever
/// touching go_router's path matching.
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
    final clean = hash.replaceFirst('#', '');
    if (clean.isEmpty) return null;
    // clean looks like "/?section=about" (or just "/" with no query).
    final uri = Uri.tryParse(clean);
    final name = uri?.queryParameters['section'];
    if (name == null) return null;
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

  // Passing `state` back unchanged (never `null`) is essential: go_router
  // stores its own routing-match metadata in `history.state`, and clobbering
  // it with `null` leaves the Router unable to restore/re-match its route
  // the next time something (e.g. a focus-change event) triggers its own
  // didChangeDependencies/restoreState cycle — it throws an internal
  // assertion trying to match against a location it no longer has state
  // context for.
  static void _replaceHash(SectionId id) {
    // Deferred a microtask: calling history.replaceState synchronously
    // inside a build/event-dispatch callback races go_router's own Router
    // widget restoreState cycle, which throws an internal assertion trying
    // to re-match the just-changed URL. Deferring avoids the reentrancy.
    scheduleMicrotask(() {
      web.window.history.replaceState(
        web.window.history.state,
        '',
        '#/?section=${_nameFor(id)}',
      );
    });
  }

  /// Reads the current `location.hash` on load.
  static SectionId? readInitialSection() =>
      sectionForHash(web.window.location.hash);
}
