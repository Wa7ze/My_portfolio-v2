import 'package:flutter/material.dart';
import '../core/tokens.dart';
import '../router.dart';

/// 404. The Pak "lost" mood treatment is phase 6 — real copy, no routing
/// regression for now.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('404 NOT FOUND', style: AppType.h1.copyWith(color: palette.textPrimary)),
            const SizedBox(height: AppSpacing.s16),
            Text('This route does not exist.', style: AppType.body.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.s32),
            FilledButton(
              onPressed: () => router.go('/'),
              child: const Text('Back home'),
            ),
          ],
        ),
      ),
    );
  }
}
