import '../../data/models/genre.dart';
import '../../data/models/subscription_plan.dart';

class ProfileState {
  const ProfileState({
    this.name = '',
    this.favoriteGenres = const [],
    this.memberSince,
    this.activePlan,
    this.remainingFreeScans = 0,
    this.isResetting = false,
    this.didReset = false,
  });

  final String name;
  final List<Genre> favoriteGenres;
  final DateTime? memberSince;
  final SubscriptionPlan? activePlan;
  final int remainingFreeScans;
  final bool isResetting;
  final bool didReset;

  bool get isPremium => activePlan != null;
}
