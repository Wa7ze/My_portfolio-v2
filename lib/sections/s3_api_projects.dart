import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/portfolio_content.dart';
import '../interaction/interactive.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 3 — API (projects). #projects, api layer, "200 OK /projects".
/// Project cards as endpoints `GET /projects/<slug>`. Full expand-in-place
/// case-study interaction is phase 3 (depends on NetButton/Interactive);
/// for now each card's overview is shown inline and the repo link opens
/// directly.
class ApiProjectsSection extends StatelessWidget {
  const ApiProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.apiProjects,
      statusLabel: '200 OK /projects',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.workPageTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s8),
          Text(strings.workPageSubtitle, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s32),
          for (final project in PortfolioContent.projects)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s24),
              child: _ProjectCard(project: project, strings: strings),
            ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final AppStrings strings;
  const _ProjectCard({required this.project, required this.strings});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: palette.bgRaised,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('GET', style: AppType.monoLabel.copyWith(color: AppColors.okGreen)),
              const SizedBox(width: AppSpacing.s8),
              Text(
                '/projects/${project.slug}',
                textDirection: TextDirection.ltr,
                style: AppType.mono.copyWith(color: palette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(project.title, style: AppType.h2Mobile.copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s8),
          Text(project.summary, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s16),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              for (final tag in project.tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.apiViolet.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(tag, style: AppType.mono.copyWith(color: AppColors.apiViolet)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Interactive(
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(project.githubUrl), mode: LaunchMode.externalApplication),
              child: Text(strings.viewOnGithub, style: AppType.monoLabel.copyWith(color: AppColors.netCyan)),
            ),
          ),
        ],
      ),
    );
  }
}
