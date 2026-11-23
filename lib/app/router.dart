import 'package:go_router/go_router.dart';

import '../data/models/media_title.dart';
import '../features/detail/detail_screen.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/recommendation/recommendation_screen.dart';
import '../features/scan/scan_request.dart';
import '../features/scan/scan_screen.dart';
import '../features/splash/splash_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const paywall = '/paywall';
  static const home = '/home';
  static const scan = '/scan';
  static const detail = '/detail';
  static const profile = '/profile';
  static const recommendation = '/recommendation';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.paywall,
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.scan,
      builder: (context, state) =>
          ScanScreen(request: state.extra! as ScanRequest),
    ),
    GoRoute(
      path: AppRoutes.detail,
      builder: (context, state) =>
          DetailScreen(title: state.extra! as MediaTitle),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.recommendation,
      builder: (context, state) => const RecommendationScreen(),
    ),
  ],
);
