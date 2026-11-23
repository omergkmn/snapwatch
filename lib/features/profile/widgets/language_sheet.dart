import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/app_languages.dart';
import '../../../core/l10n/locale_keys.g.dart';

Future<void> showLanguageSheet(BuildContext context) {
  final current = languageOf(context.locale);

  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              LocaleKeys.profile_language.tr(),
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          for (final language in appLanguages)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(language.nativeName),
              trailing: language == current
                  ? const Icon(Icons.check, color: AppColors.silver)
                  : null,
              onTap: () {
                context.setLocale(language.locale);
                Navigator.pop(sheetContext);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
