import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';

class ScanCard extends StatelessWidget {
  const ScanCard({super.key, required this.quotaText, required this.onScan});

  final String quotaText;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceLight, AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.home_scan_title.tr(),
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocaleKeys.home_scan_body.tr(),
                      style: textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _PosterStack(),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(LocaleKeys.home_scan_button.tr()),
          ),
          const SizedBox(height: 10),
          Center(child: Text(quotaText, style: textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// Three tilted poster shapes, a small hint of what the card is about.
class _PosterStack extends StatelessWidget {
  const _PosterStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 92,
      child: Stack(
        children: [
          _poster(left: 0, angle: -0.18, color: const Color(0xFF3A3D45)),
          _poster(left: 26, angle: 0.14, color: const Color(0xFF4A4E57)),
          _poster(
            left: 13,
            angle: 0,
            color: const Color(0xFF5E636D),
            child: const Icon(Icons.play_arrow, color: AppColors.silver),
          ),
        ],
      ),
    );
  }

  Widget _poster({
    required double left,
    required double angle,
    required Color color,
    Widget? child,
  }) {
    return Positioned(
      left: left,
      top: 6,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 56,
          height: 78,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.background, width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}
