import 'package:flutter/material.dart';

/// Reads the OS-level "reduce motion" / prefers-reduced-motion signal.
/// Non-essential scene motion (scroll-coupled background/Pak animation,
/// scene transitions) should shorten or skip itself when this is true.
class MotionPrefs {
  final bool reduced;
  const MotionPrefs({required this.reduced});

  static MotionPrefs of(BuildContext context) =>
      MotionPrefs(reduced: MediaQuery.of(context).disableAnimations);
}
