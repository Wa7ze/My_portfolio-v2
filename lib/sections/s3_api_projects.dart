import 'package:flutter/material.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/portfolio_content.dart';
import '../interaction/interactive.dart';
import '../interaction/net_link.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 3 — API (projects). #projects, api layer, "200 OK /projects".
/// Project cards as endpoints `GET /projects/<slug>`; tapping a card's
/// header expands it in place into a case study (PRD section 5).
class ApiProjectsSection extends StatefulWidget {
  const ApiProjectsSection({super.key});

  @override
  State<ApiProjectsSection> createState() => _ApiProjectsSectionState();
}

class _ApiProjectsSectionState extends State<ApiProjectsSection> {
  String? _expandedSlug;

  void _toggle(String slug) {
    setState(() => _expandedSlug = _expandedSlug == slug ? null : slug);
  }

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
          Semantics(
            header: true,
            child: Text(strings.workPageTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(strings.workPageSubtitle, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s32),
          for (final project in PortfolioContent.projects)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s24),
              child: _ProjectCard(
                project: project,
                strings: strings,
                expanded: _expandedSlug == project.slug,
                onToggle: () => _toggle(project.slug),
              ),
            ),
        ],
      ),
    );
  }
}

/// A fake-but-stable "response time" per project, 40-180ms, so the same
/// project always shows the same number (PRD section 5: "static fake value
/// per project").
int _responseTimeMs(String slug) => 40 + (slug.codeUnits.fold<int>(0, (a, b) => a + b) % 141);

class _ProjectCard extends StatelessWidget {
  final Project project;
  final AppStrings strings;
  final bool expanded;
  final VoidCallback onToggle;

  const _ProjectCard({
    required this.project,
    required this.strings,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final responseMs = _responseTimeMs(project.slug);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: palette.bgRaised,
        border: Border.all(color: expanded ? AppColors.apiViolet : palette.line),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Interactive(
            onTap: onToggle,
            child: Row(
              children: [
                Text('GET', style: AppType.monoLabel.copyWith(color: AppColors.okGreen)),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    '/projects/${project.slug}',
                    textDirection: TextDirection.ltr,
                    style: AppType.mono.copyWith(color: palette.textMuted),
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: palette.textMuted,
                ),
              ],
            ),
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
          AnimatedSize(
            duration: Motion.reveal,
            curve: Motion.out,
            alignment: Alignment.topCenter,
            child: expanded ? _CaseStudy(project: project) : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              NetLink(
                url: Uri.parse(project.githubUrl),
                child: Text(strings.viewOnGithub, style: AppType.monoLabel.copyWith(color: AppColors.netCyan)),
              ),
              const Spacer(),
              Text(
                '200 OK · ${responseMs}ms',
                textDirection: TextDirection.ltr,
                style: AppType.monoLabel.copyWith(color: AppColors.okGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The expanded "response body": the project's overview rendered as a
/// JSON-styled block, plus a strip of gallery images if any exist.
class _CaseStudy extends StatelessWidget {
  final Project project;
  const _CaseStudy({required this.project});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final tagsJson = project.tags.map((t) => '"$t"').join(', ');
    final body = '{\n'
        '  "slug": "${project.slug}",\n'
        '  "stack": [$tagsJson],\n'
        '  "repo": "${project.githubUrl}"\n'
        '}';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.overview, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: palette.bgSunken,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text(
              body,
              textDirection: TextDirection.ltr,
              style: AppType.mono.copyWith(color: AppColors.apiViolet),
            ),
          ),
          if (project.galleryImages.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: project.galleryImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Image.asset(project.galleryImages[i], width: 140, height: 96, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
