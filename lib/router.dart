import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/not_found_page.dart';
import 'sections/page_shell.dart';

// SelectionArea wraps each route's content here, inside go_router's own
// Navigator — wrapping it in app.dart's `builder` instead (outside the
// Router) throws "No Overlay widget found" on every build, since
// SelectableRegion needs an Overlay ancestor and the Router's own Overlay
// lives inside its routed content, not above it.
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const SelectionArea(child: PageShell()),
    ),
  ],
  errorBuilder: (context, state) => const SelectionArea(child: NotFoundPage()),
);
