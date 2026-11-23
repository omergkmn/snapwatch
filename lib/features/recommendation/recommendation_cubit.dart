import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/watch_preference.dart';
import '../../data/models/watchlist_item.dart';
import '../../data/repositories/media_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  RecommendationCubit(
    this._mediaRepository,
    this._watchlistRepository,
    this._userRepository,
  ) : super(const RecommendationState());

  final MediaRepository _mediaRepository;
  final WatchlistRepository _watchlistRepository;
  final UserRepository _userRepository;

  void preferenceToggled(WatchPreference preference) {
    final preferences = {...state.preferences};
    if (!preferences.remove(preference)) {
      // "Films only" and "Series only" cannot be selected together.
      if (preference == WatchPreference.filmOnly) {
        preferences.remove(WatchPreference.seriesOnly);
      } else if (preference == WatchPreference.seriesOnly) {
        preferences.remove(WatchPreference.filmOnly);
      }
      preferences.add(preference);
    }
    emit(state.copyWith(preferences: preferences));
  }

  void requestChanged(String request) => emit(state.copyWith(request: request));

  Future<void> submit(String languageCode) async {
    if (state.isLoading) return;

    emit(state.copyWith(status: RecommendationStatus.loading, picks: []));
    try {
      final picks = await _mediaRepository.recommend(
        // Watched titles are never sent, so they can't be recommended.
        watchlist: _watchlistRepository.items
            .where((item) => item.status == WatchStatus.toWatch)
            .map((item) => item.title)
            .toList(),
        favoriteGenres: _userRepository.profile?.favoriteGenres ?? [],
        preferences: state.preferences,
        request: state.request,
        languageCode: languageCode,
      );
      emit(state.copyWith(status: RecommendationStatus.success, picks: picks));
    } on AppException catch (e) {
      emit(state.copyWith(status: RecommendationStatus.failure, error: e.type));
    }
  }
}
