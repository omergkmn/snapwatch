import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A poster inside a focus frame with a scan line moving over it, and the
/// recognised details appearing underneath.
class ScanIllustration extends StatefulWidget {
  const ScanIllustration({super.key});

  @override
  State<ScanIllustration> createState() => _ScanIllustrationState();
}

class _ScanIllustrationState extends State<ScanIllustration>
    with SingleTickerProviderStateMixin {
  static const _posterWidth = 150.0;
  static const _posterHeight = 200.0;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 270,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: _posterWidth + 24,
                height: _posterHeight + 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const _FocusFrame(),
                    Container(
                      width: _posterWidth,
                      height: _posterHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4E535D), Color(0xFF15161A)],
                        ),
                      ),
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 44,
                        color: AppColors.silver,
                      ),
                    ),
                    Positioned(
                      top: 16 + (_posterHeight - 8) * t,
                      left: 18,
                      right: 18,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.silver,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.silver.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Opacity(
                opacity: 0.4 + 0.6 * t,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ResultPill(icon: Icons.movie_outlined, width: 34),
                    SizedBox(width: 8),
                    _ResultPill(icon: Icons.calendar_today_outlined, width: 28),
                    SizedBox(width: 8),
                    _ResultPill(icon: Icons.schedule, width: 30),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FocusFrame extends StatelessWidget {
  const _FocusFrame();

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.silver, width: 2);
    const size = 22.0;
    return const Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: side, left: side),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: side, right: side),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: side, left: side),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: side, right: side),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.icon, required this.width});

  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.silver),
          const SizedBox(width: 6),
          Container(
            width: width,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
