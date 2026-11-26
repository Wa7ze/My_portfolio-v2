import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../core/tokens.dart';
import 'interactive.dart';

enum _Phase { idle, downloading, done }

/// The CV download CTA: clicking creates and clicks a hidden anchor
/// (`package:web`, first statement — same gesture-preserving rule as
/// [NetLink]) so the file streams immediately, while the button morphs
/// into a 4-chunk progress bar in parallel (PRD section 11).
class CvDownloadButton extends StatefulWidget {
  final String label;
  const CvDownloadButton({super.key, required this.label});

  @override
  State<CvDownloadButton> createState() => _CvDownloadButtonState();
}

class _CvDownloadButtonState extends State<CvDownloadButton> {
  _Phase _phase = _Phase.idle;
  int _chunks = 0;

  static const _chunkDuration = Duration(milliseconds: 200);
  static const _chunkCount = 4;
  static const _doneHold = Duration(milliseconds: 1200);

  Future<void> _activate() async {
    if (_phase != _Phase.idle) return;

    // First statement: still inside the click gesture.
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = '/cv.pdf';
    anchor.download = 'Mazen_Matran_CV.pdf';
    anchor.click();

    setState(() {
      _phase = _Phase.downloading;
      _chunks = 0;
    });

    for (var i = 0; i < _chunkCount; i++) {
      await Future.delayed(_chunkDuration);
      if (!mounted) return;
      setState(() => _chunks = i + 1);
    }

    if (!mounted) return;
    setState(() => _phase = _Phase.done);

    await Future.delayed(_doneHold);
    if (mounted) setState(() => _phase = _Phase.idle);
  }

  @override
  Widget build(BuildContext context) {
    final busy = _phase != _Phase.idle;

    return Interactive(
      child: GestureDetector(
        onTap: busy ? null : _activate,
        child: AnimatedContainer(
          duration: Motion.handshake,
          curve: Motion.out,
          width: 180,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          decoration: BoxDecoration(
            border: Border.all(color: _phase == _Phase.done ? AppColors.okGreen : AppColors.netCyan),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          alignment: Alignment.center,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_phase) {
      case _Phase.idle:
        return Text(widget.label, style: AppType.body.copyWith(color: AppColors.netCyan), overflow: TextOverflow.ellipsis);
      case _Phase.downloading:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _chunkCount; i++)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < _chunks ? AppColors.netCyan : AppColors.netCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        );
      case _Phase.done:
        return Text(
          '200 OK · cv.pdf',
          textDirection: TextDirection.ltr,
          style: AppType.monoLabel.copyWith(color: AppColors.okGreen),
          overflow: TextOverflow.ellipsis,
        );
    }
  }
}
