import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/portfolio_content.dart';
import '../interaction/interactive.dart';
import '../interaction/net_button.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

/// Section 6 — Response (contact). #contact, response layer, "POST /contact".
/// Contact uses the PRD's own mailto: fallback (no real form endpoint yet —
/// see docs/AUDIT.md), plus the social links.
class ResponseContactSection extends StatelessWidget {
  const ResponseContactSection({super.key});

  Future<NetResult> _sendEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'mmazen0132@gmail.com', query: 'subject=Hello from Portfolio&body=Hi Mazen,');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return const NetResult.success();
    }
    return const NetResult.error(statusCode: 503, label: 'No mail client');
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.responseContact,
      statusLabel: 'POST /contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.contactTitle, style: (isMobile ? AppType.h2Mobile : AppType.h2).copyWith(color: palette.textPrimary)),
          const SizedBox(height: AppSpacing.s16),
          Text(strings.contactSubtitle, style: AppType.body.copyWith(color: palette.textSecondary)),
          const SizedBox(height: AppSpacing.s32),
          NetButton(
            label: strings.contactEmailLabel,
            icon: Icons.send,
            onRequest: _sendEmail,
          ),
          const SizedBox(height: AppSpacing.s32),
          Wrap(
            spacing: AppSpacing.s16,
            runSpacing: AppSpacing.s16,
            children: [
              for (final link in PortfolioContent.socialLinks) _SocialRow(link: link),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final SocialLink link;
  const _SocialRow({required this.link});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Interactive(
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: BoxDecoration(
            border: Border.all(color: palette.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(link.label, style: AppType.monoLabel.copyWith(color: palette.textMuted)),
              Text(link.value, style: AppType.mono.copyWith(color: AppColors.netCyan)),
            ],
          ),
        ),
      ),
    );
  }
}
