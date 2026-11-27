import type { SVGProps } from 'react';

/** Inline SVG icons (replacing the legacy Material icon font). Decorative: aria-hidden. */
type IconProps = SVGProps<SVGSVGElement>;

function Base({ children, ...props }: IconProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      width="1em"
      height="1em"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.8}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...props}
    >
      {children}
    </svg>
  );
}

export const MenuIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 7h16M4 12h16M4 17h16" />
  </Base>
);
export const CloseIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M6 6l12 12M18 6L6 18" />
  </Base>
);
export const ChevronDownIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M6 9l6 6 6-6" />
  </Base>
);
export const ChevronLeftIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M15 6l-6 6 6 6" />
  </Base>
);
export const ChevronRightIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M9 6l6 6-6 6" />
  </Base>
);
export const SendIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M21 3L10 14M21 3l-7 18-4-7-7-4 18-7z" />
  </Base>
);
export const DownloadIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M12 4v11m0 0l-4.5-4.5M12 15l4.5-4.5M5 19h14" />
  </Base>
);
export const ExternalIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M14 5h5v5M19 5l-8 8M10 6H6a1 1 0 00-1 1v11a1 1 0 001 1h11a1 1 0 001-1v-4" />
  </Base>
);
export const ExpandIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M9 4H4v5M15 4h5v5M9 20H4v-5M15 20h5v-5" />
  </Base>
);
export const MailIcon = (p: IconProps) => (
  <Base {...p}>
    <rect x="3" y="5" width="18" height="14" rx="2" />
    <path d="M3 7l9 6 9-6" />
  </Base>
);
export const PhoneIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a1 1 0 01-1 1A16 16 0 014 5a1 1 0 011-1z" />
  </Base>
);
export const LinkedinIcon = (p: IconProps) => (
  <Base {...p}>
    <rect x="3" y="3" width="18" height="18" rx="3" />
    <path d="M8 10v7M8 7v.01M12 17v-4a2 2 0 014 0v4M12 10v7" />
  </Base>
);
export const GithubIcon = (p: IconProps) => (
  <Base {...p}>
    <path d="M9 19c-4 1.5-4-2-6-2.5m12 4.5v-3.5a3 3 0 00-.9-2.3c3-.3 6-1.5 6-6.5a5 5 0 00-1.4-3.5 4.6 4.6 0 00-.1-3.5s-1.1-.3-3.6 1.4a12.4 12.4 0 00-6.4 0C6.1 2.4 5 2.7 5 2.7a4.6 4.6 0 00-.1 3.5A5 5 0 003.5 9.7c0 5 3 6.2 6 6.5a3 3 0 00-.9 2.3V22" />
  </Base>
);
