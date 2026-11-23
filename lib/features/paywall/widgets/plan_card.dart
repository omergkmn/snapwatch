import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../../../data/models/subscription_plan.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = context.locale;
    final isYearly = plan == SubscriptionPlan.yearly;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.silver : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // The badge row is always there so all cards line up.
            SizedBox(
              height: 22,
              child: isYearly
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.silver,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        LocaleKeys.paywall_savings.tr(
                          namedArgs: {
                            'percent':
                                '${SubscriptionPlan.yearlySavingsPercent}',
                          },
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            Text(plan.title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatPrice(plan.price, locale),
                style: textTheme.titleMedium?.copyWith(fontSize: 18),
              ),
            ),
            Text(plan.periodLabel, style: textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              isYearly
                  ? LocaleKeys.paywall_yearly_per_month.tr(
                      namedArgs: {
                        'price': formatPrice(plan.price / 12, locale),
                      },
                    )
                  : '',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
