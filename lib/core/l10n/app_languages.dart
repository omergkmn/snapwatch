import 'package:flutter/widgets.dart';

class AppLanguage {
  const AppLanguage(this.locale, this.nativeName);

  final Locale locale;

  /// Shown in the language's own words, so anyone can find their language.
  final String nativeName;
}

/// To add a language, add a line here and its JSON file under
/// assets/translations. The first one is the default.
const appLanguages = [
  AppLanguage(Locale('tr'), 'Türkçe'),
  AppLanguage(Locale('en'), 'English'),
];

AppLanguage languageOf(Locale locale) => appLanguages.firstWhere(
  (language) => language.locale.languageCode == locale.languageCode,
  orElse: () => appLanguages.first,
);
