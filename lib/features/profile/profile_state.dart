import '../../data/models/genre.dart';
import '../../data/models/subscription_plan.dart';

class ProfileState {
  const ProfileState({
    this.name = '',
    this.favoriteGenres = const [],
    this.memberSince,
    this.activePlan,
    this.remainingFreeScans = 0,
    this.isDeleting = false,
    this.isDeleted = false,
  });

  final String name;
  final List<Genre> favoriteGenres;
  final DateTime? memberSince;
  final SubscriptionPlan? activePlan;
  final int remainingFreeScans;
  final bool isDeleting;
  final bool isDeleted;

  bool get isPremium => activePlan != null;

  ProfileState copyWith({bool? isDeleting, bool? isDeleted}) {
    return ProfileState(
      name: name,
      favoriteGenres: favoriteGenres,
      memberSince: memberSince,
      activePlan: activePlan,
      remainingFreeScans: remainingFreeScans,
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
