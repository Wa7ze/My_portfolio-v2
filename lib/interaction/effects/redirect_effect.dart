import 'package:flutter/widgets.dart';

/// True stub — the full redirect-flyer animation (NetLink polish) is phase
/// 5. This exists only so phase 3/4 code referencing it doesn't hard-depend
/// on unbuilt phase-5 work.
class RedirectEffect extends StatelessWidget {
  const RedirectEffect({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
