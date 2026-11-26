import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/reduced_motion.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../interaction/net_button.dart';
import '../navigation/nav_controller.dart';
import '../navigation/section_registry.dart';
import '../scroll/scroll_progress.dart';
import 'section_scaffold.dart';

/// Section 7 — Teardown (footer). "FIN", response layer. Plays the TCP
/// teardown sequence (PRD section 12) once [ScrollProgress.ended] fires:
/// a client/server ladder diagram draws its four FIN/ACK rows, then a
/// closing card with the Keep-Alive button back to the top. Also renders
/// the EOF overscroll marker, driven by [ScrollProgress.pull].
class TeardownFooterSection extends StatefulWidget {
  const TeardownFooterSection({super.key});

  @override
  State<TeardownFooterSection> createState() => _TeardownFooterSectionState();
}

class _TeardownFooterSectionState extends State<TeardownFooterSection> with SingleTickerProviderStateMixin {
  late final AnimationController _seq;
  bool _lastEnded = false;

  static const _totalMs = 2700;
  static const _rowStartMs = [500, 880, 1260, 1640];
  static const _cardStartMs = 2100;

  @override
  void initState() {
    super.initState();
    _seq = AnimationController(vsync: this, duration: const Duration(milliseconds: _totalMs));
  }

  @override
  void dispose() {
    _seq.dispose();
    super.dispose();
  }

  double _localT(int startMs, int durationMs) {
    final elapsed = _seq.value * _totalMs - startMs;
    return (elapsed / durationMs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = AppPalette.of(context);
    final ended = context.watch<ScrollProgress>().ended;
    final reduced = MotionPrefs.of(context).reduced;

    if (ended != _lastEnded) {
      _lastEnded = ended;
      if (ended) {
        reduced ? _seq.value = 1 : _seq.forward(from: 0);
      } else {
        _seq.value = 0;
      }
    }

    return SectionScaffold(
      id: SectionId.teardownFooter,
      statusLabel: 'FIN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _seq,
            builder: (context, _) => _LadderDiagram(seq: this, palette: palette),
          ),
          const SizedBox(height: AppSpacing.s32),
          AnimatedBuilder(
            animation: _seq,
            builder: (context, _) {
              final t = _localT(_cardStartMs, Motion.reveal.inMilliseconds);
              if (t <= 0) return const SizedBox.shrink();
              final eased = Motion.out.transform(t);
              return Opacity(
                opacity: eased,
                child: Transform.translate(
                  offset: Offset(0, (1 - eased) * 12),
                  child: _ClosingCard(strings: strings, palette: palette),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s24),
          _EofMarker(palette: palette),
          const SizedBox(height: AppSpacing.s24),
          Text('© ${DateTime.now().year} ${strings.footerRights}', style: AppType.mono.copyWith(color: palette.textMuted)),
          const SizedBox(height: AppSpacing.s4),
          Text(strings.footerBuiltWith, style: AppType.mono.copyWith(color: palette.textMuted)),
        ],
      ),
    );
  }
}

class _LadderDiagram extends StatelessWidget {
  final _TeardownFooterSectionState seq;
  final AppPalette palette;
  const _LadderDiagram({required this.seq, required this.palette});

  static const _rows = ['FIN →', '← ACK', '← FIN', 'ACK →'];

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    final gap = isMobile ? 200.0 : 320.0;

    return SizedBox(
      width: gap + 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('client', style: AppType.monoLabel.copyWith(color: palette.textMuted)),
              SizedBox(width: gap - 70),
              Text('server', style: AppType.monoLabel.copyWith(color: palette.textMuted)),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: _buildRow(i, gap),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(int index, double gap) {
    final t = seq._localT(_TeardownFooterSectionState._rowStartMs[index], Motion.teardownStep.inMilliseconds);
    if (t <= 0) return SizedBox(height: 18, width: gap);
    final toRight = _rows[index].endsWith('→');
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: SizedBox(
        width: gap,
        height: 18,
        child: Align(
          alignment: toRight ? Alignment.centerLeft : Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: Motion.out.transform(t),
            alignment: toRight ? Alignment.centerLeft : Alignment.centerRight,
            child: Row(
              mainAxisAlignment: toRight ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Text(_rows[index], textDirection: TextDirection.ltr, style: AppType.mono.copyWith(color: AppColors.okGreen)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClosingCard extends StatelessWidget {
  final AppStrings strings;
  final AppPalette palette;
  const _ClosingCard({required this.strings, required this.palette});

  Future<NetResult> _keepAlive(BuildContext context) async {
    context.read<NavController>().goTo(context, SectionId.browserHero, fixedDuration: Motion.keepAlive);
    return const NetResult.success();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connection closed.', style: AppType.h2.copyWith(color: palette.textPrimary)),
        const SizedBox(height: AppSpacing.s8),
        Text('Thanks for visiting.', style: AppType.body.copyWith(color: palette.textSecondary)),
        const SizedBox(height: AppSpacing.s24),
        NetButton(label: 'Keep-Alive ↻', onRequest: () => _keepAlive(context)),
      ],
    );
  }
}

class _EofMarker extends StatelessWidget {
  final AppPalette palette;
  const _EofMarker({required this.palette});

  @override
  Widget build(BuildContext context) {
    final pull = context.watch<ScrollProgress>().pull;
    return Opacity(
      opacity: pull,
      child: Transform.translate(
        offset: Offset(0, pull * 16),
        child: Transform.scale(
          scaleY: 1 + pull * 0.6,
          child: Text('EOF', textDirection: TextDirection.ltr, style: AppType.mono.copyWith(color: palette.textMuted)),
        ),
      ),
    );
  }
}
