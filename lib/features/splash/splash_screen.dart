import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../data/repositories/user_repository.dart';
import 'splash_cubit.dart';
import 'splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(context.read<UserRepository>())..start(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigate) {
            context.go(switch (state.destination) {
              SplashDestination.onboarding => AppRoutes.onboarding,
              SplashDestination.home => AppRoutes.home,
            });
          }
        },
        child: const _SplashView(),
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Snapwatch', style: textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                LocaleKeys.splash_tagline.tr(),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              // Fills up over the same time the cubit waits before moving on.
              SizedBox(
                width: 140,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: SplashCubit.minimumDuration,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.silver,
                    backgroundColor: AppColors.border,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
