import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_plan.dart';
import '../models/user_profile.dart';
import '../models/watchlist_item.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _userProfileKey = 'user_profile';
  static const _activePlanKey = 'active_plan';
  static const _scanCountKey = 'scan_count';
  static const _watchlistKey = 'watchlist';

  bool get isOnboardingCompleted =>
      _prefs.getBool(_onboardingCompletedKey) ?? false;

  Future<void> setOnboardingCompleted() =>
      _prefs.setBool(_onboardingCompletedKey, true);

  UserProfile? readUserProfile() {
    final json = _prefs.getString(_userProfileKey);
    if (json == null) return null;
    return UserProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveUserProfile(UserProfile profile) =>
      _prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));

  SubscriptionPlan? readActivePlan() {
    final name = _prefs.getString(_activePlanKey);
    return name == null ? null : SubscriptionPlan.values.byName(name);
  }

  Future<void> saveActivePlan(SubscriptionPlan plan) =>
      _prefs.setString(_activePlanKey, plan.name);

  int get scanCount => _prefs.getInt(_scanCountKey) ?? 0;

  Future<void> saveScanCount(int count) => _prefs.setInt(_scanCountKey, count);

  List<WatchlistItem> readWatchlist() {
    final json = _prefs.getString(_watchlistKey);
    if (json == null) return [];
    return (jsonDecode(json) as List<dynamic>)
        .map((item) => WatchlistItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Removes only this app's keys; the language choice is kept.
  Future<void> clearAll() async {
    for (final key in [
      _onboardingCompletedKey,
      _userProfileKey,
      _activePlanKey,
      _scanCountKey,
      _watchlistKey,
    ]) {
      await _prefs.remove(key);
    }
  }

  Future<void> saveWatchlist(List<WatchlistItem> items) => _prefs.setString(
    _watchlistKey,
    jsonEncode(items.map((item) => item.toJson()).toList()),
  );
}
