import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';
import 'section_scaffold.dart';

const _kCvPdfAsset = 'assets/files/Mazen_Matran_CV.pdf';

/// Section 0 — Browser (hero). #home, browser layer, "GET / HTTP/1.1".
/// Static for now — the real NetButton handshake state machine and
/// traceroute-driven navigation land in phases 3-4.
class BrowserHeroSection extends StatelessWidget {
  const BrowserHeroSection({super.key});

  Future<void> _downloadCv() async {
    // Flutter web serves pubspec assets under an extra `assets/` prefix.
    final uri = Uri.base.resolve('assets/$_kCvPdfAsset');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _viewProjects(BuildContext context) {
    final target = SectionRegistry.keyFor(SectionId.apiProjects).currentContext;
    if (target != null) {
      Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return SectionScaffold(
      id: SectionId.browserHero,
      statusLabel: 'GET / HTTP/1.1',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mazen Matran',
            style: (isMobile ? AppType.h1Mobile : AppType.display).copyWith(color: palette.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            strings.heroTitle,
            style: (isMobile ? AppType.h2Mobile : AppType.h1).copyWith(color: AppColors.netCyan),
          ),
          const SizedBox(height: AppSpacing.s24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              strings.heroSubtitle,
              style: AppType.body.copyWith(color: palette.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.s48),
          Wrap(
            spacing: AppSpacing.s16,
            runSpacing: AppSpacing.s16,
            children: [
              ElevatedButton(
                onPressed: () => _viewProjects(context),
                child: Text(strings.heroCtaWork),
              ),
              OutlinedButton(
                onPressed: _downloadCv,
                child: Text(strings.downloadCvButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
