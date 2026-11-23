import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../../../data/models/genre.dart';
import '../onboarding_cubit.dart';

class OnboardingGenresPage extends StatelessWidget {
  const OnboardingGenresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = context.select(
      (OnboardingCubit cubit) => cubit.state.genres,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.onboarding_genres_title.tr(),
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.onboarding_genres_body.tr(),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final genre in Genre.values)
                FilterChip(
                  label: Text(genre.label),
                  selected: selected.contains(genre),
                  onSelected: (_) =>
                      context.read<OnboardingCubit>().genreToggled(genre),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
