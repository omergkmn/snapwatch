import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/user_repository.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._userRepository) : super(const SplashInitial());

  final UserRepository _userRepository;

  static const minimumDuration = Duration(milliseconds: 1500);

  Future<void> start() async {
    await Future<void>.delayed(minimumDuration);
    if (isClosed) return;

    final destination = _userRepository.isOnboardingCompleted
        ? SplashDestination.home
        : SplashDestination.onboarding;
    emit(SplashNavigate(destination));
  }
}
