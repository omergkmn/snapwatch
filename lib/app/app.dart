import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/media_repository.dart';
import '../data/repositories/subscription_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/watchlist_repository.dart';
import '../data/services/auth_service.dart';
import '../data/services/gemini_service.dart';
import '../data/services/local_storage_service.dart';
import 'app_environment.dart';
import 'router.dart';
import 'theme.dart';

class SnapwatchApp extends StatelessWidget {
  const SnapwatchApp({
    super.key,
    required this.environment,
    required this.storage,
  });

  final AppEnvironment environment;
  final LocalStorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) =>
              UserRepository(storage, AuthService(FirebaseAuth.instance)),
        ),
        RepositoryProvider(
          create: (context) => SubscriptionRepository(storage),
        ),
        RepositoryProvider(
          create: (context) => MediaRepository(GeminiService()),
        ),
        RepositoryProvider(create: (context) => WatchlistRepository(storage)),
      ],
      child: MaterialApp.router(
        title: environment.isDev ? 'Snapwatch Dev' : 'Snapwatch',
        debugShowCheckedModeBanner: environment.isDev,
        theme: AppTheme.dark,
        routerConfig: appRouter,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        builder: (context, child) {
          if (!environment.isDev) return child!;
          return Banner(
            message: 'DEV',
            location: BannerLocation.topStart,
            child: child,
          );
        },
      ),
    );
  }
}
