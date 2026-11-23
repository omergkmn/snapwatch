import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../../../data/models/media_title.dart';
import '../../../data/models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.isBestMatch,
    required this.onTap,
  });

  final Recommendation recommendation;
  final bool isBestMatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = recommendation.title;
    final meta = [
      title.type == MediaType.film
          ? LocaleKeys.detail_film.tr()
          : LocaleKeys.detail_series.tr(),
      if (title.year != null) '${title.year}',
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title.title, style: textTheme.titleMedium),
                  ),
                  if (isBestMatch)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.silver,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        LocaleKeys.recommend_best_match.tr(),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(meta, style: textTheme.bodySmall),
              if (recommendation.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(recommendation.reason, style: textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
