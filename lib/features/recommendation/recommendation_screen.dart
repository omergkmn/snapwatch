import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../data/models/watch_preference.dart';
import '../../data/repositories/media_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import 'recommendation_cubit.dart';
import 'recommendation_state.dart';
import 'widgets/recommendation_card.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecommendationCubit(
        context.read<MediaRepository>(),
        context.read<WatchlistRepository>(),
        context.read<UserRepository>(),
      ),
      child: const _RecommendationView(),
    );
  }
}

class _RecommendationView extends StatelessWidget {
  const _RecommendationView();

  void _onStatusChanged(BuildContext context, RecommendationState state) {
    if (state.status == RecommendationStatus.failure) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.error!.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecommendationCubit>().state;
    final cubit = context.read<RecommendationCubit>();
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<RecommendationCubit, RecommendationState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            Text(
              LocaleKeys.recommend_title.tr(),
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preference in WatchPreference.values)
                  FilterChip(
                    label: Text(preference.label),
                    selected: state.preferences.contains(preference),
                    onSelected: (_) => cubit.preferenceToggled(preference),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLength: 120,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: LocaleKeys.recommend_request_hint.tr(),
                counterText: '',
              ),
              onChanged: cubit.requestChanged,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      cubit.submit(context.locale.languageCode);
                    },
              child: state.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(LocaleKeys.recommend_submit.tr()),
            ),
            if (state.picks.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                LocaleKeys.recommend_results_title.tr(),
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              for (final (index, pick) in state.picks.indexed) ...[
                RecommendationCard(
                  recommendation: pick,
                  isBestMatch: index == 0,
                  onTap: () =>
                      context.push(AppRoutes.detail, extra: pick.title),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
