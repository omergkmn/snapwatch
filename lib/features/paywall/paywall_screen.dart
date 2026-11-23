import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/open_link.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/repositories/subscription_repository.dart';
import 'paywall_cubit.dart';
import 'paywall_state.dart';
import 'widgets/feature_comparison.dart';
import 'widgets/plan_card.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaywallCubit(context.read<SubscriptionRepository>()),
      child: const _PaywallView(),
    );
  }
}

class _PaywallView extends StatefulWidget {
  const _PaywallView();

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  static const _closeButtonDelay = Duration(seconds: 3);

  // The yearly plan sits in the middle so it gets the most attention.
  static const _planOrder = [
    SubscriptionPlan.weekly,
    SubscriptionPlan.yearly,
    SubscriptionPlan.monthly,
  ];

  Timer? _closeButtonTimer;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _closeButtonTimer = Timer(_closeButtonDelay, () {
      setState(() => _canClose = true);
    });
  }

  @override
  void dispose() {
    _closeButtonTimer?.cancel();
    super.dispose();
  }

  // The paywall opens after onboarding (nothing to go back to) or on top of
  // another screen later on, so it either pops or replaces itself with home.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onStatusChanged(BuildContext context, PaywallState state) {
    switch (state.status) {
      case PaywallStatus.purchased:
        _showMessage(LocaleKeys.paywall_purchased.tr());
        _leave();
      case PaywallStatus.restored:
        _showMessage(LocaleKeys.paywall_restored.tr());
        _leave();
      case PaywallStatus.nothingToRestore:
        _showMessage(LocaleKeys.paywall_nothing_to_restore.tr());
      case PaywallStatus.idle:
      case PaywallStatus.purchasing:
      case PaywallStatus.restoring:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PaywallCubit>().state;
    final cubit = context.read<PaywallCubit>();
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<PaywallCubit, PaywallState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _canClose) _leave();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      opacity: _canClose ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _canClose ? _leave : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.paywall_title.tr(),
                          style: textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.paywall_subtitle.tr(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const FeatureComparison(),
                        const SizedBox(height: 24),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final plan in _planOrder) ...[
                                if (plan != _planOrder.first)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: PlanCard(
                                    plan: plan,
                                    isSelected: plan == state.selectedPlan,
                                    onTap: () => cubit.planSelected(plan),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: state.isBusy ? null : cubit.purchase,
                        child: state.status == PaywallStatus.purchasing
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(LocaleKeys.paywall_subscribe.tr()),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocaleKeys.paywall_cancel_anytime.tr(),
                        style: textTheme.bodySmall,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _FooterLink(
                            label: LocaleKeys.paywall_restore.tr(),
                            onTap: state.isBusy ? null : cubit.restore,
                          ),
                          _FooterLink(
                            label: LocaleKeys.paywall_terms.tr(),
                            onTap: () => openLink(AppLinks.terms),
                          ),
                          _FooterLink(
                            label: LocaleKeys.paywall_privacy.tr(),
                            onTap: () => openLink(AppLinks.privacy),
                          ),
                        ],
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

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
