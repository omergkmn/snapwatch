import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../data/models/genre.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/models/watch_preference.dart';
import '../errors/app_exception.dart';
import 'locale_keys.g.dart';

extension GenreLabel on Genre {
  String get label => switch (this) {
    Genre.action => LocaleKeys.genres_action,
    Genre.comedy => LocaleKeys.genres_comedy,
    Genre.drama => LocaleKeys.genres_drama,
    Genre.sciFi => LocaleKeys.genres_sci_fi,
    Genre.thriller => LocaleKeys.genres_thriller,
    Genre.horror => LocaleKeys.genres_horror,
    Genre.romance => LocaleKeys.genres_romance,
    Genre.animation => LocaleKeys.genres_animation,
    Genre.documentary => LocaleKeys.genres_documentary,
    Genre.crime => LocaleKeys.genres_crime,
  }.tr();
}

extension AppErrorMessage on AppErrorType {
  String get message => switch (this) {
    AppErrorType.network => LocaleKeys.errors_network,
    AppErrorType.notMedia => LocaleKeys.errors_not_media,
    AppErrorType.emptyWatchlist => LocaleKeys.errors_empty_watchlist,
    AppErrorType.noMatch => LocaleKeys.errors_no_match,
    AppErrorType.unknown => LocaleKeys.errors_unknown,
  }.tr();
}

extension SubscriptionPlanText on SubscriptionPlan {
  String get title => switch (this) {
    SubscriptionPlan.weekly => LocaleKeys.paywall_plan_weekly,
    SubscriptionPlan.monthly => LocaleKeys.paywall_plan_monthly,
    SubscriptionPlan.yearly => LocaleKeys.paywall_plan_yearly,
  }.tr();

  String get periodLabel => switch (this) {
    SubscriptionPlan.weekly => LocaleKeys.paywall_period_weekly,
    SubscriptionPlan.monthly => LocaleKeys.paywall_period_monthly,
    SubscriptionPlan.yearly => LocaleKeys.paywall_period_yearly,
  }.tr();
}

extension WatchPreferenceLabel on WatchPreference {
  String get label => switch (this) {
    WatchPreference.short => LocaleKeys.recommend_pref_short,
    WatchPreference.thrilling => LocaleKeys.recommend_pref_thrilling,
    WatchPreference.light => LocaleKeys.recommend_pref_light,
    WatchPreference.filmOnly => LocaleKeys.recommend_pref_film_only,
    WatchPreference.seriesOnly => LocaleKeys.recommend_pref_series_only,
  }.tr();
}

String formatPrice(double price, Locale locale) {
  return NumberFormat.currency(
    locale: locale.languageCode,
    symbol: '₺',
  ).format(price);
}
