import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'terminal_overlay.dart' deferred as terminal;

/// Lets other widgets (the nav bar's logo, on long-press) request the
/// terminal open without depending on the deferred library themselves.
class TerminalLauncherController extends ChangeNotifier {
  VoidCallback? _handler;

  void attach(VoidCallback handler) => _handler = handler;
  void detach(VoidCallback handler) {
    if (identical(_handler, handler)) _handler = null;
  }

  void requestOpen() => _handler?.call();
}

/// Wraps the whole app: listens for the backtick/`~` global hotkey (ignored
/// while a text field has focus) and exposes [TerminalLauncherController]
/// for the nav bar's long-press-the-logo trigger. Loads the terminal's
/// deferred library only on the first actual open.
class TerminalLauncher extends StatefulWidget {
  final TerminalLauncherController controller;
  final Widget child;
  const TerminalLauncher({super.key, required this.controller, required this.child});

  @override
  State<TerminalLauncher> createState() => _TerminalLauncherState();
}

class _TerminalLauncherState extends State<TerminalLauncher> {
  bool _loaded = false;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
    widget.controller.attach(_toggle);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    widget.controller.detach(_toggle);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.backquote) return false;
    final focusedWidget = FocusManager.instance.primaryFocus?.context?.widget;
    if (focusedWidget is EditableText) return false;
    _toggle();
    return true;
  }

  Future<void> _toggle() async {
    if (_open) {
      setState(() => _open = false);
      return;
    }
    if (!_loaded) {
      await terminal.loadLibrary();
      if (!mounted) return;
      _loaded = true;
    }
    setState(() => _open = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_open && _loaded) terminal.TerminalOverlay(onClose: () => setState(() => _open = false)),
      ],
    );
  }
}
