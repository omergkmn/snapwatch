import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../data/models/media_title.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../../core/widgets/poster_placeholder.dart';
import 'detail_cubit.dart';
import 'widgets/platform_list.dart';
import 'widgets/watchlist_actions.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.title});

  final MediaTitle title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final originalTitle = title.originalTitle;
    final creatorLabel = title.type == MediaType.film
        ? LocaleKeys.detail_director.tr()
        : LocaleKeys.detail_creator.tr();

    return BlocProvider(
      create: (context) =>
          DetailCubit(context.read<WatchlistRepository>(), title),
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        bottomNavigationBar: const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: WatchlistActions(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PosterPlaceholder(title: title.title, width: 96, height: 136),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.title, style: textTheme.headlineSmall),
                      if (originalTitle != null && originalTitle != title.title)
                        Text(originalTitle, style: textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Wrap(spacing: 6, runSpacing: 6, children: _infoChips()),
                    ],
                  ),
                ),
              ],
            ),
            if (title.genres.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final genre in title.genres) _GenreTag(label: genre),
                ],
              ),
            ],
            if (title.creator != null) ...[
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(creatorLabel, style: textTheme.bodySmall),
                  subtitle: Text(title.creator!, style: textTheme.titleMedium),
                ),
              ),
            ],
            if (title.overview.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                LocaleKeys.detail_overview.tr(),
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                title.overview,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              LocaleKeys.detail_where_to_watch.tr(),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            PlatformList(
              platforms: title.platforms,
              searchTitle: originalTitle ?? title.title,
              year: title.year,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _infoChips() {
    final isFilm = title.type == MediaType.film;
    return [
      _InfoChip(
        icon: isFilm ? Icons.movie_outlined : Icons.live_tv_outlined,
        text: isFilm
            ? LocaleKeys.detail_film.tr()
            : LocaleKeys.detail_series.tr(),
      ),
      if (title.year != null)
        _InfoChip(icon: Icons.calendar_today_outlined, text: '${title.year}'),
      if (isFilm && title.runtimeMinutes != null)
        _InfoChip(
          icon: Icons.schedule,
          text: LocaleKeys.detail_minutes.tr(args: ['${title.runtimeMinutes}']),
        ),
      if (!isFilm && title.seasonCount != null)
        _InfoChip(
          icon: Icons.layers_outlined,
          text: LocaleKeys.detail_seasons.plural(title.seasonCount!),
        ),
    ];
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.silver),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
