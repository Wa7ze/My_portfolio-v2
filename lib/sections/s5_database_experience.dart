import 'package:flutter/material.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 5 — Database (experience). #experience, database layer,
/// "SELECT * FROM experience". TODO(content): the PRD implies a multi-row
/// timeline; audited content has exactly one job entry — shipped as a
/// single result row per docs/AUDIT.md (user-confirmed).
class DatabaseExperienceSection extends StatelessWidget {
  const DatabaseExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.databaseExperience,
      statusLabel: 'SELECT * FROM experience',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.experienceTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s24),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: palette.bgRaised,
              border: Border.all(color: palette.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('row 1', style: AppType.monoLabel.copyWith(color: AppColors.dbAmber)),
                    const Spacer(),
                    Text(strings.experiencePeriod, style: AppType.mono.copyWith(color: palette.textMuted)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(strings.experienceRole, style: AppType.body.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w700)),
                Text(strings.experienceCompany, style: AppType.mono.copyWith(color: palette.textSecondary)),
                const SizedBox(height: AppSpacing.s16),
                for (final bullet in strings.experienceBullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('> ', style: AppType.mono.copyWith(color: AppColors.dbAmber)),
                        Expanded(child: Text(bullet, style: AppType.body.copyWith(color: palette.textSecondary))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
