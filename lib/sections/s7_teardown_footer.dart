import 'package:flutter/material.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 7 — Teardown (footer). "FIN", response layer. Minimal static
/// footer for phases 0-4 — the full TCP-teardown sequence is phase 5.
class TeardownFooterSection extends StatelessWidget {
  const TeardownFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);

    return SectionScaffold(
      id: SectionId.teardownFooter,
      statusLabel: 'FIN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('© ${DateTime.now().year} ${strings.footerRights}', style: AppType.mono.copyWith(color: palette.textMuted)),
          const SizedBox(height: AppSpacing.s4),
          Text(strings.footerBuiltWith, style: AppType.mono.copyWith(color: palette.textMuted)),
        ],
      ),
    );
  }
}
