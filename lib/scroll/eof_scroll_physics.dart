import 'package:flutter/material.dart';

/// [BouncingScrollPhysics] clamped at the top (no bounce before the start
/// of the page) but left free to bounce at the bottom, where the teardown
/// section's EOF marker reacts to the overscroll (PRD section 12).
class EofScrollPhysics extends BouncingScrollPhysics {
  const EofScrollPhysics({super.parent});

  @override
  EofScrollPhysics applyTo(ScrollPhysics? ancestor) => EofScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      // Dragging further up while already at (or before) the top: clamp.
      return value - position.minScrollExtent;
    }
    return 0.0;
  }
}
