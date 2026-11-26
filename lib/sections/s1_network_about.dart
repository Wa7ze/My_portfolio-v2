import 'package:flutter/material.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/portfolio_content.dart';
import '../interaction/net_link.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 1 — Network (about). #about, network layer, "TLS 1.3 handshake ok".
/// Bio, current role, education, and (folded in per docs/AUDIT.md) the 9
/// certificates — this section has no dedicated slot in the PRD's 8-section
/// list, so they live here as supporting records.
class NetworkAboutSection extends StatelessWidget {
  const NetworkAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.networkAbout,
      statusLabel: 'TLS 1.3 handshake ok',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.summaryTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s16),
          Text(strings.summaryBody, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s12),
          Text(
            '${strings.experienceRole} — ${strings.experienceCompany} (${strings.experiencePeriod})',
            style: AppType.mono.copyWith(color: AppColors.netCyan),
          ),
          const SizedBox(height: AppSpacing.s48),
          Text(strings.educationTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s16),
          ...strings.educationEntries.map(
            (edu) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${edu.degree} — ${edu.field}', style: AppType.body.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w700)),
                  Text(edu.school, style: AppType.mono.copyWith(color: palette.textSecondary)),
                  Text('${edu.gpa} · ${edu.period}', style: AppType.mono.copyWith(color: palette.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s48),
          Text(strings.certificatesTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s8),
          Text(strings.certificatesSubtitle, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s24),
          _CertificateList(entries: PortfolioContent.featuredCertificates, strings: strings),
          const SizedBox(height: AppSpacing.s24),
          Text(strings.otherCertificatesLabel, style: AppType.monoLabel.copyWith(color: palette.textMuted)),
          const SizedBox(height: AppSpacing.s12),
          _CertificateList(entries: PortfolioContent.otherCertificates, strings: strings),
        ],
      ),
    );
  }
}

class _CertificateList extends StatelessWidget {
  final List<CertificateEntry> entries;
  final AppStrings strings;
  const _CertificateList({required this.entries, required this.strings});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cert in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: palette.bgRaised,
                border: Border.all(color: palette.line),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cert.title, style: AppType.body.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.s4),
                  Text(cert.issuer, style: AppType.mono.copyWith(color: palette.textSecondary)),
                  Text(cert.date, style: AppType.mono.copyWith(color: palette.textMuted)),
                  if (cert.url != null) ...[
                    const SizedBox(height: AppSpacing.s8),
                    NetLink(
                      url: Uri.parse(cert.url!),
                      child: Text(
                        strings.verificationLinkLabel,
                        style: AppType.monoLabel.copyWith(color: AppColors.netCyan),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
