import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../scene/pak/pak_state.dart';
import 'effects_controller.dart';
import 'interactive.dart';

/// An external (or mailto) link modeled as a tiny "301 redirect": launches
/// immediately on tap — before any animation — since browsers block
/// `window.open`/downloads that happen after an async delay once they're no
/// longer inside the user gesture. See PRD section 11.
class NetLink extends StatelessWidget {
  final Widget child;
  final Uri url;

  const NetLink({super.key, required this.child, required this.url});

  void _activate(BuildContext context) {
    // First statement, synchronous: the browser gesture is still "live".
    launchUrl(url, mode: LaunchMode.externalApplication);

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final globalCenter = box.localToGlobal(box.size.center(Offset.zero));
    final isEmail = url.scheme == 'mailto';
    context.read<EffectsController>().addRedirect(
          globalCenter,
          label: isEmail ? 'SMTP 250 OK' : '301 Moved Permanently',
        );
    context.read<PakController>().react(PakMood.waving);
  }

  @override
  Widget build(BuildContext context) {
    return Interactive(
      child: GestureDetector(
        onTap: () => _activate(context),
        child: child,
      ),
    );
  }
}
