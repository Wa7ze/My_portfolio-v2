import 'package:flutter/material.dart';

/// One station per section along the request path, in fixed page order.
enum SectionId {
  browserHero,
  networkAbout,
  gatewaySkills,
  apiProjects,
  logicApproach,
  databaseExperience,
  responseContact,
  teardownFooter,
}

/// GlobalKeys + measured scroll offsets for every section. Offsets are
/// filled in by [measure] (called by the page shell after every layout
/// pass) and consumed by [ScrollProgress]/[NavController] in later phases.
abstract final class SectionRegistry {
  static final Map<SectionId, GlobalKey> _keys = {
    for (final id in SectionId.values) id: GlobalKey(debugLabel: id.name),
  };

  static final Map<SectionId, double> _offsets = {
    for (final id in SectionId.values) id: 0.0,
  };

  static GlobalKey keyFor(SectionId id) => _keys[id]!;

  static double offsetFor(SectionId id) => _offsets[id] ?? 0.0;

  /// Re-measures every section's top offset relative to [scrollableContext]
  /// (the scrollable's own RenderBox) plus the controller's current scroll
  /// position, so offsets stay correct regardless of current scroll
  /// position or viewport size.
  static void measure(BuildContext scrollableContext, ScrollController controller) {
    final scrollableBox = scrollableContext.findRenderObject() as RenderBox?;
    if (scrollableBox == null || !scrollableBox.attached || !scrollableBox.hasSize) return;
    final scrollableOrigin = scrollableBox.localToGlobal(Offset.zero);

    for (final id in SectionId.values) {
      final box = _keys[id]!.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;
      final sectionOrigin = box.localToGlobal(Offset.zero);
      _offsets[id] = (sectionOrigin.dy - scrollableOrigin.dy) + controller.offset;
    }
  }
}
