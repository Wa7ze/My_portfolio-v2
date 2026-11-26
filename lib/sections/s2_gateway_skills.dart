import 'package:flutter/material.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 2 — Gateway (skills). #skills, gateway layer, "ROUTE /skills".
/// Skill groups rendered as route-table entries.
class GatewaySkillsSection extends StatelessWidget {
  const GatewaySkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.gatewaySkills,
      statusLabel: 'ROUTE /skills',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.skillsTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s24),
          ...strings.skillGroups.entries.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('ROUTE', style: AppType.monoLabel.copyWith(color: AppColors.apiViolet)),
                      const SizedBox(width: AppSpacing.s8),
                      Text('/${group.key.toLowerCase().replaceAll(' ', '-').replaceAll('&', 'and')}',
                          style: AppType.mono.copyWith(color: palette.textMuted)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(group.key, style: AppType.body.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      for (final skill in group.value)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                          decoration: BoxDecoration(
                            border: Border.all(color: palette.line),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(skill, style: AppType.mono.copyWith(color: palette.textSecondary)),
                        ),
                    ],
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
