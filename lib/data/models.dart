/// Plain content models for the structurally-new PRD content (projects,
/// certificates, social links, approach principles). Translatable prose
/// (bio, experience, education, skills, languages) continues to flow
/// through the existing lib/core/strings/ AppStrings mechanism — these
/// models are locale-independent by design, matching how the current app
/// already treats project and certificate content as English-only
/// regardless of the active locale (see docs/AUDIT.md).
library;

class Project {
  final String slug;
  final String title;
  final String imageUrl;
  final String summary;
  final List<String> tags;
  final String githubUrl;
  final List<String> galleryImages;
  final String overview;

  const Project({
    required this.slug,
    required this.title,
    required this.imageUrl,
    required this.summary,
    required this.tags,
    required this.githubUrl,
    required this.galleryImages,
    required this.overview,
  });
}

class CertificateEntry {
  final String title;
  final String issuer;
  final String date;
  final String? imageAsset;
  final String? url;

  const CertificateEntry({
    required this.title,
    required this.issuer,
    required this.date,
    this.imageAsset,
    this.url,
  });
}

class SocialLink {
  final String label;
  final String value;
  final String url;

  const SocialLink({required this.label, required this.value, required this.url});
}

/// Section 4 (Logic/approach) principle. No source content exists for this
/// section yet — see TODO(content) in docs/AUDIT.md.
class ApproachPrinciple {
  final String title;
  final String body;

  const ApproachPrinciple({required this.title, required this.body});
}
