import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_environment.dart';
import 'core/l10n/app_languages.dart';
import 'data/services/local_storage_service.dart';
import 'firebase_options.dart';

// Passed at build time (--dart-define-from-file), never committed.
const _androidDebugToken = String.fromEnvironment(
  'APP_CHECK_ANDROID_DEBUG_TOKEN',
);
const _iosDebugToken = String.fromEnvironment('APP_CHECK_IOS_DEBUG_TOKEN');

Future<void> mainCommon(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _activateAppCheck();
  await EasyLocalization.ensureInitialized();
  final storage = LocalStorageService(await SharedPreferences.getInstance());

  runApp(
    EasyLocalization(
      supportedLocales: [for (final language in appLanguages) language.locale],
      path: 'assets/translations',
      startLocale: appLanguages.first.locale,
      fallbackLocale: appLanguages.first.locale,
      child: SnapwatchApp(environment: environment, storage: storage),
    ),
  );
}

/// Firebase AI Logic only accepts requests with a valid App Check token.
/// Emulators and sideloaded builds can't pass Play Integrity / App Attest,
/// so a registered debug token is used when one is provided.
Future<void> _activateAppCheck() {
  return FirebaseAppCheck.instance.activate(
    providerAndroid: _androidDebugToken.isEmpty
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(debugToken: _androidDebugToken),
    providerApple: _iosDebugToken.isEmpty
        ? const AppleAppAttestWithDeviceCheckFallbackProvider()
        : const AppleDebugProvider(debugToken: _iosDebugToken),
  );
}
