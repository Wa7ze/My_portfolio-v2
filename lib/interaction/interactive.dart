import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/tokens.dart';
import '../widgets/custom_cursor.dart';
import 'handled_pointers.dart';

/// Wrap any tappable widget that isn't already a [NetButton] with this so
/// [ClickRouter] doesn't mistake its press for an empty click on blank
/// canvas. Claims the pointer on `pointerDown`, before the wrapped widget's
/// own gesture recognizer wins the arena. Reports hover to
/// [CursorController] so the custom cursor grows its "open port" ring.
///
/// Pass [onTap] (and optionally [onLongPress]) to make this the widget's
/// actual activation handler — that also makes it keyboard-focusable
/// (Tab order, a visible focus ring, Enter/Space activation). Omitting
/// both keeps the old behavior of just marking the pointer handled, for a
/// child that already owns its own tap handling (e.g. [NetButton], which
/// has its own `Focus`).
class Interactive extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const Interactive({super.key, required this.child, this.onTap, this.onLongPress});

  @override
  State<Interactive> createState() => _InteractiveState();
}

class _InteractiveState extends State<Interactive> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handled = context.read<HandledPointers>();
    final cursor = context.read<CursorController>();

    final tracked = MouseRegion(
      onEnter: (_) => cursor.enter(),
      onExit: (_) => cursor.exit(),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) => handled.add(event.pointer),
        child: widget.child,
      ),
    );

    if (widget.onTap == null && widget.onLongPress == null) {
      return tracked;
    }

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: (node, event) {
        if (widget.onTap != null &&
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space)) {
          widget.onTap!.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: _focused
              ? BoxDecoration(
                  border: Border.all(color: AppColors.netCyan, width: 2),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                )
              : null,
          child: tracked,
        ),
      ),
    );
  }
}
