import type { MouseEvent, ReactNode } from 'react';
import { wire } from '../../content/strings';
import { centerOf, useEffects } from '../../state/effects';

/**
 * External / mailto link modeled as a tiny redirect (legacy lib/interaction/net_link.dart).
 * It is a real <a>, so the browser opens it immediately inside the click; the
 * "301 Moved Permanently" (or "SMTP 250 OK" for mailto) badge is purely decorative.
 */
export function NetLink({
  href,
  children,
  className = '',
  ariaLabel,
}: {
  href: string;
  children: ReactNode;
  className?: string;
  ariaLabel?: string;
}) {
  const { addRedirect } = useEffects();
  const isMail = href.startsWith('mailto:');

  function onClick(e: MouseEvent<HTMLAnchorElement>) {
    const { x, y } = centerOf(e.currentTarget);
    addRedirect(x, y, isMail ? wire.badges.smtp : wire.badges.redirect);
  }

  return (
    <a
      href={href}
      onClick={onClick}
      aria-label={ariaLabel}
      {...(isMail ? {} : { target: '_blank', rel: 'noopener noreferrer' })}
      className={className}
    >
      {children}
    </a>
  );
}
