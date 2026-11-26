import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_cursor.dart';
import 'handled_pointers.dart';

/// Wrap any tappable widget that isn't already a [NetButton] with this so
/// [ClickRouter] doesn't mistake its press for an empty click on blank
/// canvas. Claims the pointer on `pointerDown`, before the wrapped widget's
/// own gesture recognizer wins the arena. Also reports hover to
/// [CursorController] so the custom cursor grows its "open port" ring.
class Interactive extends StatelessWidget {
  final Widget child;
  const Interactive({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final handled = context.read<HandledPointers>();
    final cursor = context.read<CursorController>();
    return MouseRegion(
      onEnter: (_) => cursor.enter(),
      onExit: (_) => cursor.exit(),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) => handled.add(event.pointer),
        child: child,
      ),
    );
  }
}
