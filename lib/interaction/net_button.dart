import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/reduced_motion.dart';
import '../core/tokens.dart';
import 'effects_controller.dart';
import 'interactive.dart';

enum NetButtonVariant { primary, ghost }

/// The outcome of a [NetButton]'s fake network request.
class NetResult {
  final bool success;
  final int statusCode;
  final String label;

  const NetResult.success({this.statusCode = 200, this.label = 'OK'}) : success = true;
  const NetResult.error({this.statusCode = 500, this.label = 'Error'}) : success = false;
}

enum _Phase { idle, handshaking, success, error }

/// Models every interaction as a fake network request: press -> handshake
/// (300ms, 3-leg) -> success/error with a status-code badge. Wraps
/// [Interactive] so [ClickRouter] never double-counts a press as an empty
/// click.
class NetButton extends StatefulWidget {
  final String label;
  final NetButtonVariant variant;
  final IconData? icon;
  final Future<NetResult> Function() onRequest;

  const NetButton({
    super.key,
    required this.label,
    this.variant = NetButtonVariant.primary,
    this.icon,
    required this.onRequest,
  });

  @override
  State<NetButton> createState() => _NetButtonState();
}

class _NetButtonState extends State<NetButton> {
  _Phase _phase = _Phase.idle;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (_phase != _Phase.idle) return;
    final reduced = MotionPrefs.of(context).reduced;

    if (!reduced) {
      setState(() => _phase = _Phase.handshaking);
      await Future.delayed(Motion.handshake);
      if (!mounted) return;
    }

    NetResult result;
    try {
      result = await widget.onRequest();
    } catch (_) {
      result = const NetResult.error();
    }
    if (!mounted) return;

    setState(() => _phase = result.success ? _Phase.success : _Phase.error);
    _showBadge(result);

    await Future.delayed(reduced ? Duration.zero : Motion.badgeFloat);
    if (mounted) setState(() => _phase = _Phase.idle);
  }

  void _showBadge(NetResult result) {
    if (!result.success) {
      // Errors carry meaning the floating badge alone won't reach a
      // screen reader with (it's decorative/transient, not focusable).
      SemanticsService.announce('${result.statusCode} ${result.label}', TextDirection.ltr, assertiveness: Assertiveness.assertive);
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final globalCenter = box.localToGlobal(box.size.center(Offset.zero));
    context.read<EffectsController>().addBadge(
          globalCenter,
          statusCode: result.statusCode,
          label: result.label,
          isError: !result.success,
        );
  }

  @override
  Widget build(BuildContext context) {
    final handshaking = _phase == _Phase.handshaking;
    final isError = _phase == _Phase.error;
    final isSuccess = _phase == _Phase.success;
    final borderColor = isError
        ? AppColors.errRed
        : isSuccess
            ? AppColors.okGreen
            : null;

    Widget button = widget.variant == NetButtonVariant.primary
        ? FilledButton(onPressed: handshaking ? null : _activate, child: _buildChild(handshaking))
        : OutlinedButton(
            onPressed: handshaking ? null : _activate,
            style: borderColor != null ? OutlinedButton.styleFrom(side: BorderSide(color: borderColor)) : null,
            child: _buildChild(handshaking),
          );

    return Interactive(
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space)) {
            _activate();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: button,
      ),
    );
  }

  Widget _buildChild(bool handshaking) {
    if (handshaking) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(widget.label),
        ],
      );
    }
    if (widget.icon == null) return Text(widget.label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 18),
        const SizedBox(width: AppSpacing.s8),
        Text(widget.label),
      ],
    );
  }
}
