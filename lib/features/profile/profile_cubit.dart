import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._userRepository, this._subscriptionRepository)
    : super(const ProfileState());

  final UserRepository _userRepository;
  final SubscriptionRepository _subscriptionRepository;

  void refresh() {
    final profile = _userRepository.profile;
    emit(
      ProfileState(
        name: profile?.name ?? '',
        favoriteGenres: profile?.favoriteGenres ?? [],
        memberSince: _userRepository.memberSince,
        activePlan: _subscriptionRepository.activePlan,
        remainingFreeScans: _subscriptionRepository.remainingFreeScans,
      ),
    );
  }

  Future<void> deleteAccount() async {
    if (state.isDeleting) return;

    // The profile stays on screen until the app moves to onboarding.
    emit(state.copyWith(isDeleting: true));
    await _userRepository.deleteAccount();
    emit(state.copyWith(isDeleted: true));
  }
}
