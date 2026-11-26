import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/tokens.dart';

/// Lets [PageShell] register the [FocusNode] that wraps its main content,
/// so the "Skip to content" link (rendered in `app.dart`, above the nav
/// bar in focus order) can jump keyboard focus straight past the nav bar
/// without either widget needing to know about the other directly.
class SkipLinkController extends ChangeNotifier {
  FocusNode? _target;

  void attach(FocusNode node) => _target = node;
  void detach(FocusNode node) {
    if (identical(_target, node)) _target = null;
  }

  void activate() => _target?.requestFocus();
}

/// Visually hidden until focused (standard "skip to content" pattern):
/// the first focusable element on the page, so keyboard users don't have
/// to Tab through the whole nav bar on every page load.
class SkipLink extends StatefulWidget {
  final SkipLinkController controller;
  const SkipLink({super.key, required this.controller});

  @override
  State<SkipLink> createState() => _SkipLinkState();
}

class _SkipLinkState extends State<SkipLink> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _focused ? 8 : -48,
      left: 8,
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space)) {
            widget.controller.activate();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.controller.activate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
            decoration: BoxDecoration(
              color: AppColors.netCyan,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Text('Skip to content', style: TextStyle(color: Color(0xFF0A0E1A), fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
