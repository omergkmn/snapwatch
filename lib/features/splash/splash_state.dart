enum SplashDestination { onboarding, home }

sealed class SplashState {
  const SplashState();
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashNavigate extends SplashState {
  const SplashNavigate(this.destination);

  final SplashDestination destination;
}
