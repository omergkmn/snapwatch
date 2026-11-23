import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A social media post that floats up and down, with a "saved" badge.
class SaveIllustration extends StatefulWidget {
  const SaveIllustration({super.key});

  @override
  State<SaveIllustration> createState() => _SaveIllustrationState();
}

class _SaveIllustrationState extends State<SaveIllustration>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return SizedBox(
          width: 250,
          height: 270,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -6 + 12 * t),
                child: Transform.rotate(angle: -0.06, child: child),
              ),
              Positioned(
                right: 8,
                bottom: 24,
                child: Transform.scale(
                  scale: 0.9 + 0.12 * t,
                  child: const _SavedBadge(),
                ),
              ),
            ],
          ),
        );
      },
      child: const _PostCard(),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: AppColors.surfaceLight),
              SizedBox(width: 8),
              _Bar(width: 70),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5B606B), Color(0xFF1A1B1F)],
                ),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 40,
                color: AppColors.silver,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.chat_bubble_outline,
                size: 15,
                color: AppColors.textSecondary,
              ),
              Spacer(),
              Icon(
                Icons.bookmark_border,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedBadge extends StatelessWidget {
  const _SavedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.silver,
        border: Border.all(color: AppColors.background, width: 4),
      ),
      child: const Icon(Icons.bookmark_added, color: AppColors.background),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
