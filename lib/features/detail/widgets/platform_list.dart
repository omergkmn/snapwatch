import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../../../core/open_link.dart';
import '../../../core/platform_links.dart';

class PlatformList extends StatelessWidget {
  const PlatformList({
    super.key,
    required this.platforms,
    required this.searchTitle,
    this.year,
  });

  final List<String> platforms;
  final String searchTitle;
  final int? year;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // When the AI knows no platform, let the user look it up on the web.
    if (platforms.isEmpty) {
      final query = [
        searchTitle,
        if (year != null) '$year',
        LocaleKeys.detail_search_query_suffix.tr(),
      ].join(' ');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(LocaleKeys.detail_no_platforms.tr(), style: textTheme.bodySmall),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => openLink(webSearchUrl(query)),
            icon: const Icon(Icons.search),
            label: Text(LocaleKeys.detail_search_where_to_watch.tr()),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Column(
            children: [
              for (final platform in platforms)
                ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceLight,
                    foregroundColor: AppColors.silver,
                    child: Text(
                      platform.characters.first.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  title: Text(platform, style: textTheme.bodyMedium),
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => openLink(
                    platformSearchUrl(platform: platform, title: searchTitle),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(LocaleKeys.detail_platforms_note.tr(), style: textTheme.bodySmall),
      ],
    );
  }
}
