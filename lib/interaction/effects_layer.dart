import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'effects/ping_effect.dart';
import 'effects/redirect_effect.dart';
import 'effects/status_badge_effect.dart';
import 'effects/traceroute_effect.dart';
import 'effects_controller.dart';
import 'toast_controller.dart';

/// The single overlay layer for every transient interaction effect — no
/// showDialog/OverlayEntry spam. Converts each effect's stored global
/// position into this layer's own local coordinate space via its own
/// RenderBox, so callers never need to know this layer's position in the
/// tree.
class EffectsLayer extends StatelessWidget {
  const EffectsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final effects = context.watch<EffectsController>();
    return IgnorePointer(
      child: Builder(
        builder: (innerContext) {
          Offset toLocal(Offset global) {
            final box = innerContext.findRenderObject() as RenderBox?;
            if (box == null || !box.hasSize) return global;
            return box.globalToLocal(global);
          }

          return Stack(
            children: [
              for (final ping in effects.pings)
                PingEffect(key: ValueKey(ping.id), position: toLocal(ping.globalPosition), label: ping.label),
              for (final badge in effects.badges)
                StatusBadgeEffect(
                  key: ValueKey(badge.id),
                  position: toLocal(badge.globalPosition),
                  statusCode: badge.statusCode,
                  label: badge.label,
                  isError: badge.isError,
                ),
              for (final redirect in effects.redirects)
                RedirectEffect(key: ValueKey(redirect.id), position: toLocal(redirect.globalPosition), label: redirect.label),
              if (effects.traceroute case final tr?)
                TracerouteEffect(fromLength: tr.fromLength, toLength: tr.toLength),
            ],
          );
        },
      ),
    );
  }
}

/// A minimal, visible banner for [ToastController] — bottom-centered,
/// auto-hiding. Full idle/toast polish is phase 6.
class ToastHost extends StatelessWidget {
  const ToastHost({super.key});

  @override
  Widget build(BuildContext context) {
    final toast = context.watch<ToastController>().current;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: toast == null
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : Padding(
                  key: ValueKey(toast.id),
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _ToastBubble(toast: toast),
                ),
        ),
      ),
    );
  }
}

class _ToastBubble extends StatelessWidget {
  final ToastEntry toast;
  const _ToastBubble({required this.toast});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: toast.isError ? const Color(0xFFF87171) : const Color(0xFF4ADE80)),
          ),
          child: Text(toast.message, style: theme.textTheme.bodyMedium),
        );
      },
    );
  }
}
