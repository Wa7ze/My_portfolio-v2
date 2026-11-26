import 'package:flutter/material.dart';
import '../core/tokens.dart';
import '../data/portfolio_content.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 4 — Logic (approach). #approach, logic layer, "fn handle(req)".
/// TODO(content): no source content exists for this section's principles —
/// see docs/AUDIT.md. Rendered as a call stack of visible placeholders,
/// not invented opinions.
class LogicApproachSection extends StatelessWidget {
  const LogicApproachSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.logicApproach,
      statusLabel: 'fn handle(req)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Approach', style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          ),
          const SizedBox(height: AppSpacing.s24),
          for (int i = 0; i < PortfolioContent.approachPrinciples.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: palette.bgRaised,
                  border: Border.all(color: palette.line),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${' ' * i}#${i + 1}',
                      textDirection: TextDirection.ltr,
                      style: AppType.mono.copyWith(color: AppColors.dbAmber),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PortfolioContent.approachPrinciples[i].title,
                            style: AppType.body.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            PortfolioContent.approachPrinciples[i].body,
                            style: AppType.mono.copyWith(color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
