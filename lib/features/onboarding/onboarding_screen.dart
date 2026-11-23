import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../data/repositories/user_repository.dart';
import 'onboarding_cubit.dart';
import 'onboarding_state.dart';
import 'widgets/illustrations/save_illustration.dart';
import 'widgets/illustrations/scan_illustration.dart';
import 'widgets/onboarding_genres_page.dart';
import 'widgets/onboarding_info_page.dart';
import 'widgets/onboarding_name_page.dart';
import 'widgets/page_dots.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(context.read<UserRepository>()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  static const _pageCount = 4;

  final _pageController = PageController();
  int _page = 0;

  bool get _isLastPage => _page == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    FocusScope.of(context).unfocus();
    setState(() => _page = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onContinue() {
    if (_isLastPage) {
      context.read<OnboardingCubit>().submit();
    } else {
      _goToPage(_page + 1);
    }
  }

  void _onStatusChanged(BuildContext context, OnboardingState state) {
    switch (state.status) {
      case OnboardingStatus.completed:
        context.go(AppRoutes.paywall);
      case OnboardingStatus.failure:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error!.message)));
      case OnboardingStatus.editing:
      case OnboardingStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;
    final canContinue = switch (_page) {
      2 => state.hasGenres,
      3 => state.hasName,
      _ => true,
    };

    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: PopScope(
        canPop: _page == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goToPage(_page - 1);
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _page > 0
                        ? IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                            onPressed: () => _goToPage(_page - 1),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      OnboardingInfoPage(
                        illustration: const SaveIllustration(),
                        title: LocaleKeys.onboarding_save_title.tr(),
                        body: LocaleKeys.onboarding_save_body.tr(),
                      ),
                      OnboardingInfoPage(
                        illustration: const ScanIllustration(),
                        title: LocaleKeys.onboarding_recognize_title.tr(),
                        body: LocaleKeys.onboarding_recognize_body.tr(),
                      ),
                      const OnboardingGenresPage(),
                      const OnboardingNamePage(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    children: [
                      PageDots(count: _pageCount, current: _page),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: canContinue && !state.isSubmitting
                            ? _onContinue
                            : null,
                        child: state.isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLastPage
                                    ? LocaleKeys.onboarding_start.tr()
                                    : LocaleKeys.onboarding_continue.tr(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
