import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/genre.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._userRepository) : super(const OnboardingState());

  final UserRepository _userRepository;

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void genreToggled(Genre genre) {
    final genres = {...state.genres};
    if (!genres.remove(genre)) genres.add(genre);
    emit(state.copyWith(genres: genres));
  }

  Future<void> submit() async {
    if (!state.hasName || !state.hasGenres || state.isSubmitting) return;

    emit(state.copyWith(status: OnboardingStatus.submitting));
    try {
      await _userRepository.completeOnboarding(
        UserProfile(
          name: state.name.trim(),
          favoriteGenres: Genre.values.where(state.genres.contains).toList(),
        ),
      );
      emit(state.copyWith(status: OnboardingStatus.completed));
    } on AppException catch (e) {
      emit(state.copyWith(status: OnboardingStatus.failure, error: e.type));
    }
  }
}
