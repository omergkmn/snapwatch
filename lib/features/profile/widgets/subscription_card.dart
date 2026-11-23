import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/locale_keys.g.dart';
import '../profile_state.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.state,
    required this.onUpgrade,
  });

  final ProfileState state;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plan = state.activePlan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              plan == null
                  ? LocaleKeys.profile_free_plan.tr()
                  : LocaleKeys.profile_premium_plan.tr(
                      namedArgs: {'plan': plan.title},
                    ),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              plan == null
                  ? LocaleKeys.home_free_scans_left.plural(
                      state.remainingFreeScans,
                    )
                  : LocaleKeys.profile_premium_benefits.tr(),
              style: textTheme.bodySmall,
            ),
            if (plan == null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onUpgrade,
                child: Text(LocaleKeys.profile_upgrade.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
