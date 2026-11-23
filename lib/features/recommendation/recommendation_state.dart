import '../../core/errors/app_exception.dart';
import '../../data/models/recommendation.dart';
import '../../data/models/watch_preference.dart';

enum RecommendationStatus { editing, loading, success, failure }

class RecommendationState {
  const RecommendationState({
    this.preferences = const {},
    this.request = '',
    this.status = RecommendationStatus.editing,
    this.picks = const [],
    this.error,
  });

  final Set<WatchPreference> preferences;
  final String request;
  final RecommendationStatus status;
  final List<Recommendation> picks;
  final AppErrorType? error;

  bool get isLoading => status == RecommendationStatus.loading;

  RecommendationState copyWith({
    Set<WatchPreference>? preferences,
    String? request,
    RecommendationStatus? status,
    List<Recommendation>? picks,
    AppErrorType? error,
  }) {
    return RecommendationState(
      preferences: preferences ?? this.preferences,
      request: request ?? this.request,
      status: status ?? this.status,
      picks: picks ?? this.picks,
      error: error,
    );
  }
}
