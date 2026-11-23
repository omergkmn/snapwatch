import 'dart:async';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../scan_state.dart';

class ScanningView extends StatefulWidget {
  const ScanningView({
    super.key,
    required this.image,
    required this.step,
    this.error,
    this.isComplete = false,
    this.onFinished,
  });

  final Uint8List image;

  /// The step the scan has really reached.
  final ScanStep step;
  final AppErrorType? error;

  /// True when the result is ready; [onFinished] is called once the list
  /// has shown the last step.
  final bool isComplete;
  final VoidCallback? onFinished;

  @override
  State<ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<ScanningView>
    with SingleTickerProviderStateMixin {
  static const _labels = {
    ScanStep.reading: LocaleKeys.scan_step_reading,
    ScanStep.recognizing: LocaleKeys.scan_step_recognizing,
    ScanStep.details: LocaleKeys.scan_step_details,
    ScanStep.finishing: LocaleKeys.scan_step_finishing,
  };

  // Each step stays on screen at least this long so it can be read; the
  // list follows the real step and never runs ahead of it.
  static const _minStepTime = Duration(milliseconds: 600);

  late final _scanLine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Timer _stepTimer;
  int _shownStep = 0;
  bool _finishedCalled = false;

  @override
  void initState() {
    super.initState();
    _stepTimer = Timer.periodic(_minStepTime, (_) => _advance());
  }

  void _advance() {
    final target = widget.step.index;
    if (_shownStep < target) {
      setState(() => _shownStep++);
    } else if (widget.isComplete &&
        _shownStep == ScanStep.finishing.index &&
        !_finishedCalled) {
      _finishedCalled = true;
      widget.onFinished?.call();
    }
  }

  @override
  void dispose() {
    _stepTimer.cancel();
    _scanLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
          child: Column(
            children: [
              const Spacer(),
              _ScannedImage(
                image: widget.image,
                animation: error == null ? _scanLine : null,
              ),
              const SizedBox(height: 36),
              if (error == null)
                for (final step in ScanStep.values)
                  _StepRow(
                    text: _labels[step]!.tr(),
                    isDone: step.index < _shownStep,
                    isActive: step.index == _shownStep,
                  )
              else ...[
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  error.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const Spacer(),
              if (error != null)
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(LocaleKeys.scan_back.tr()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannedImage extends StatelessWidget {
  const _ScannedImage({required this.image, required this.animation});

  final Uint8List image;
  final Animation<double>? animation;

  static const _width = 170.0;
  static const _height = 240.0;

  @override
  Widget build(BuildContext context) {
    final animation = this.animation;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(image, fit: BoxFit.cover),
            Container(color: AppColors.background.withValues(alpha: 0.25)),
            if (animation != null)
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) => Align(
                  alignment: Alignment(0, -1 + 2 * animation.value),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.silver,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.silver.withValues(alpha: 0.7),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.text,
    required this.isDone,
    required this.isActive,
  });

  final String text;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isPending = !isDone && !isActive;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isPending ? 0.35 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: isActive
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.silver,
                    )
                  : Icon(
                      isDone ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: AppColors.silver,
                    ),
            ),
            const SizedBox(width: 14),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
