import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../data/models/media_title.dart';
import '../../../data/models/watchlist_item.dart';

class WatchlistTile extends StatelessWidget {
  const WatchlistTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final WatchlistItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = item.title;
    final meta = [
      title.type == MediaType.film
          ? LocaleKeys.detail_film.tr()
          : LocaleKeys.detail_series.tr(),
      if (title.year != null) '${title.year}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onRemove(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
        child: Card(
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            leading: PosterImage(
              title: title.title,
              posterUrl: title.posterUrl,
            ),
            title: Text(title.title, style: textTheme.titleMedium),
            subtitle: Text(meta, style: textTheme.bodySmall),
            trailing: item.status == WatchStatus.watched
                ? const Icon(Icons.check_circle, color: AppColors.silver)
                : const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}
