import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../onboarding_cubit.dart';

class OnboardingNamePage extends StatelessWidget {
  const OnboardingNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _AvatarPreview(),
          const SizedBox(height: 28),
          Text(
            LocaleKeys.onboarding_name_title.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 32),
          TextFormField(
            initialValue: context.read<OnboardingCubit>().state.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 30,
            decoration: InputDecoration(
              hintText: LocaleKeys.onboarding_name_hint.tr(),
              counterText: '',
            ),
            onChanged: context.read<OnboardingCubit>().nameChanged,
            onFieldSubmitted: (_) => context.read<OnboardingCubit>().submit(),
          ),
        ],
      ),
    );
  }
}

/// Shows the first letter of the name while the user types it.
class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview();

  @override
  Widget build(BuildContext context) {
    final name = context.select((OnboardingCubit cubit) => cubit.state.name);
    final initial = name.trim().isEmpty
        ? null
        : name.trim().characters.first.toUpperCase();

    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.silver, width: 1.5),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: initial == null
            ? const Icon(
                Icons.person_outline,
                key: ValueKey('empty'),
                size: 40,
                color: AppColors.textSecondary,
              )
            : Text(
                initial,
                key: ValueKey(initial),
                style: Theme.of(context).textTheme.displaySmall,
              ),
      ),
    );
  }
}
