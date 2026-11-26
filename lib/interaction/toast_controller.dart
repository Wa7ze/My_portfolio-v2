import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';

/// Minimal toast queue — enough to surface NetButton errors and the 429
/// rate-limit response. Full idle/toast polish is phase 6; this is the
/// smallest version that gives real, visible feedback now.
class ToastEntry {
  final Object id;
  final String message;
  final bool isError;
  const ToastEntry({required this.id, required this.message, required this.isError});
}

class ToastController extends ChangeNotifier {
  ToastEntry? _current;
  ToastEntry? get current => _current;

  static const _displayDuration = Duration(milliseconds: 2200);

  void show(String message, {bool isError = false}) {
    final entry = ToastEntry(id: UniqueKey(), message: message, isError: isError);
    _current = entry;
    notifyListeners();
    // Toasts carry meaning (429, 408, reconnected) — screen readers would
    // otherwise never see this transient, non-focusable banner.
    SemanticsService.announce(message, TextDirection.ltr);
    Future.delayed(_displayDuration, () {
      if (_current?.id == entry.id) {
        _current = null;
        notifyListeners();
      }
    });
  }
}
