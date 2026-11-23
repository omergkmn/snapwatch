import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';

class FeatureComparison extends StatelessWidget {
  const FeatureComparison({super.key});

  static const _columnWidth = 64.0;

  /// Feature text key and whether the free plan includes it.
  static const _features = [
    (LocaleKeys.paywall_feature_scan, true),
    (LocaleKeys.paywall_feature_watchlist, true),
    (LocaleKeys.paywall_feature_unlimited, false),
    (LocaleKeys.paywall_feature_tonight, false),
    (LocaleKeys.paywall_feature_genres, false),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              SizedBox(
                width: _columnWidth,
                child: Text(
                  LocaleKeys.paywall_compare_free.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: _columnWidth,
                child: Text(
                  LocaleKeys.paywall_compare_premium.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.silver,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final (textKey, inFree) in _features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      textKey.tr(),
                      style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                  ),
                  SizedBox(
                    width: _columnWidth,
                    child: inFree
                        ? const Icon(Icons.check, color: AppColors.silver)
                        : const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  const SizedBox(
                    width: _columnWidth,
                    child: Icon(Icons.check_circle, color: AppColors.silver),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
