import '../../core/errors/app_exception.dart';
import '../../data/models/genre.dart';

enum OnboardingStatus { editing, submitting, completed, failure }

class OnboardingState {
  const OnboardingState({
    this.name = '',
    this.genres = const {},
    this.status = OnboardingStatus.editing,
    this.error,
  });

  final String name;
  final Set<Genre> genres;
  final OnboardingStatus status;
  final AppErrorType? error;

  bool get hasGenres => genres.isNotEmpty;
  bool get hasName => name.trim().isNotEmpty;
  bool get isSubmitting => status == OnboardingStatus.submitting;

  OnboardingState copyWith({
    String? name,
    Set<Genre>? genres,
    OnboardingStatus? status,
    AppErrorType? error,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      error: error,
    );
  }
}
