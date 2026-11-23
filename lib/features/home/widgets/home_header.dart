import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/locale_keys.g.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.name, required this.onProfile});

  final String name;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.home_greeting.tr(namedArgs: {'name': name}),
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(LocaleKeys.home_subtitle.tr(), style: textTheme.bodySmall),
            ],
          ),
        ),
        IconButton.outlined(
          onPressed: onProfile,
          icon: const Icon(Icons.person_outline),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.silver,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ],
    );
  }
}
