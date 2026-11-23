import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../../../data/models/watchlist_item.dart';
import '../detail_cubit.dart';

class WatchlistActions extends StatelessWidget {
  const WatchlistActions({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<DetailCubit>().state;
    final cubit = context.read<DetailCubit>();

    if (status == null) {
      return FilledButton.icon(
        onPressed: cubit.addToWatchlist,
        icon: const Icon(Icons.bookmark_add_outlined),
        label: Text(LocaleKeys.detail_add.tr()),
      );
    }

    final isWatched = status == WatchStatus.watched;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWatched)
          OutlinedButton(
            onPressed: () => cubit.setWatched(false),
            child: Text(LocaleKeys.detail_mark_unwatched.tr()),
          )
        else
          FilledButton.icon(
            onPressed: () => cubit.setWatched(true),
            icon: const Icon(Icons.check),
            label: Text(LocaleKeys.detail_mark_watched.tr()),
          ),
        TextButton(
          onPressed: cubit.removeFromWatchlist,
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: Text(LocaleKeys.detail_remove.tr()),
        ),
      ],
    );
  }
}
