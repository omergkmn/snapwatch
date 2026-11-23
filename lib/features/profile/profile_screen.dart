import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/l10n/app_languages.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../core/open_link.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';
import 'widgets/language_sheet.dart';
import 'widgets/settings_group.dart';
import 'widgets/subscription_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        context.read<UserRepository>(),
        context.read<SubscriptionRepository>(),
      )..refresh(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _openPaywall(BuildContext context) async {
    await context.push(AppRoutes.paywall);
    if (context.mounted) context.read<ProfileCubit>().refresh();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.profile_delete_title.tr()),
        content: Text(LocaleKeys.profile_delete_body.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(LocaleKeys.profile_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(LocaleKeys.profile_delete_confirm.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProfileCubit>().deleteAccount();
    }
  }

  String _memberText(DateTime? memberSince) {
    if (memberSince == null) return LocaleKeys.profile_guest.tr();
    return LocaleKeys.profile_guest_since.tr(
      namedArgs: {'date': DateFormat('dd.MM.yyyy').format(memberSince)},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileCubit>().state;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => current.isDeleted,
      listener: (context, state) => context.go(AppRoutes.onboarding),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(LocaleKeys.profile_title.tr()),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.silver,
                      child: Text(
                        state.name.isEmpty ? '?' : state.name.characters.first,
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.name, style: textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            _memberText(state.memberSince),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                LocaleKeys.profile_subscription.tr(),
                style: textTheme.bodySmall,
              ),
            ),
            SubscriptionCard(
              state: state,
              onUpgrade: () => _openPaywall(context),
            ),
            SettingsGroup(
              title: LocaleKeys.profile_settings.tr(),
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(LocaleKeys.profile_language.tr()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        languageOf(context.locale).nativeName,
                        style: textTheme.bodySmall,
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => showLanguageSheet(context),
                ),
                ListTile(
                  leading: const Icon(Icons.movie_outlined),
                  title: Text(LocaleKeys.profile_favorite_genres.tr()),
                  subtitle: Text(
                    state.favoriteGenres.map((genre) => genre.label).join(', '),
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            SettingsGroup(
              title: LocaleKeys.profile_about.tr(),
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(LocaleKeys.paywall_terms.tr()),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => openLink(AppLinks.terms),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(LocaleKeys.paywall_privacy.tr()),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => openLink(AppLinks.privacy),
                ),
              ],
            ),
            SettingsGroup(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: Text(
                    LocaleKeys.profile_delete_account.tr(),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  enabled: !state.isDeleting,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
