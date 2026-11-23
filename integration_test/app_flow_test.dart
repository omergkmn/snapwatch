import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:snapwatch/app/app_environment.dart';
import 'package:snapwatch/core/l10n/l10n_extensions.dart';
import 'package:snapwatch/core/l10n/locale_keys.g.dart';
import 'package:snapwatch/data/models/genre.dart';
import 'package:snapwatch/features/detail/detail_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:snapwatch/app/router.dart';
import 'package:snapwatch/features/home/home_cubit.dart';
import 'package:snapwatch/features/home/widgets/scan_card.dart';
import 'package:snapwatch/features/home/widgets/tonight_card.dart';
import 'package:snapwatch/features/scan/scan_request.dart';
import 'package:snapwatch/features/onboarding/onboarding_screen.dart';
import 'package:snapwatch/features/paywall/paywall_screen.dart';
import 'package:snapwatch/features/profile/profile_screen.dart';
import 'package:snapwatch/features/recommendation/widgets/recommendation_card.dart';
import 'package:snapwatch/main_common.dart';

import 'sample_images.dart';

/// Walks through the whole app on a real device or simulator, including the
/// real Firebase and Gemini calls. The gallery picker is a system screen, so
/// the scan is started on the cubit with a bundled sample image instead.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isAndroid ? 'android' : 'ios';

  testWidgets('full app flow', timeout: const Timeout(Duration(minutes: 6)), (
    tester,
  ) async {
    var shotIndex = 0;

    Future<void> waitFor(Finder finder, {int seconds = 20}) async {
      final end = DateTime.now().add(Duration(seconds: seconds));
      while (finder.evaluate().isEmpty) {
        if (DateTime.now().isAfter(end)) {
          fail('Timed out waiting for $finder');
        }
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> shot(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      shotIndex++;
      final index = shotIndex.toString().padLeft(2, '0');
      await binding.takeScreenshot('$platform-$index-$name');
    }

    // ensureVisible also scrolls horizontal page views, so it is only used
    // for vertical lists.
    Future<void> tapText(String text, {bool scroll = false}) async {
      if (scroll) {
        await tester.ensureVisible(find.text(text));
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.tap(find.text(text));
      await tester.pump(const Duration(milliseconds: 400));
    }

    // Same as the system back button / swipe.
    Future<void> goBack() async {
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 600));
    }

    // Opens the scan screen the same way home does after the gallery picker.
    Future<void> scan(String base64Image) async {
      final context = tester.element(find.byType(ScanCard));
      context.push(
        AppRoutes.scan,
        extra: ScanRequest(
          image: base64Decode(base64Image),
          mimeType: 'image/jpeg',
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Home refreshes itself when its own push returns; the test pushed the
    // scan screen directly, so it refreshes home by hand.
    Future<void> backToHome() async {
      await goBack();
      await waitFor(find.byType(ScanCard));
      tester.element(find.byType(ScanCard)).read<HomeCubit>().refresh();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await mainCommon(AppEnvironment.dev);
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    // Splash -> onboarding
    await tester.pump();
    await shot('splash');
    await waitFor(find.byType(OnboardingScreen));
    await shot('onboarding-save');
    await tapText(LocaleKeys.onboarding_continue.tr());
    await shot('onboarding-recognize');
    await tapText(LocaleKeys.onboarding_continue.tr());
    await tapText(Genre.sciFi.label);
    await tapText(Genre.thriller.label);
    await shot('onboarding-genres');
    await tapText(LocaleKeys.onboarding_continue.tr());
    await tester.enterText(find.byType(TextFormField), 'Ömer');
    await shot('onboarding-name');
    await tapText(LocaleKeys.onboarding_start.tr());

    // Paywall: restore with nothing to restore, then close after 3 s
    await waitFor(find.byType(PaywallScreen));
    await shot('paywall');
    await tapText(LocaleKeys.paywall_restore.tr());
    await waitFor(find.text(LocaleKeys.paywall_nothing_to_restore.tr()));
    await shot('paywall-nothing-to-restore');
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
    await waitFor(find.byType(ScanCard));
    await shot('home-free');

    // Scan a film, add it to the list
    await scan(arrivalPoster);
    await tester.pump(const Duration(seconds: 2));
    await shot('scanning');
    await waitFor(find.byType(DetailScreen), seconds: 60);
    await shot('detail-film');
    await tapText(LocaleKeys.detail_add.tr(), scroll: true);
    await shot('detail-film-added');
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await shot('detail-film-platforms');
    await backToHome();

    // Scan a series, add it and mark it as watched
    await scan(breakingBadPoster);
    await waitFor(find.byType(DetailScreen), seconds: 60);
    await shot('detail-series');
    await tapText(LocaleKeys.detail_add.tr(), scroll: true);
    await tapText(LocaleKeys.detail_mark_watched.tr(), scroll: true);
    await shot('detail-series-watched');
    await backToHome();
    await shot('home-watchlist');
    await tapText(LocaleKeys.home_tab_watched.tr());
    await shot('home-watched-tab');
    await tapText(LocaleKeys.home_tab_to_watch.tr());

    // A non-media image shows an error and does not use a free scan
    await scan(shoppingListImage);
    await waitFor(find.text(LocaleKeys.errors_not_media.tr()), seconds: 60);
    await shot('scan-not-media');
    await backToHome();

    // Locked recommendation opens the paywall; buy the monthly plan
    await tester.tap(find.byType(TonightCard));
    await waitFor(find.byType(PaywallScreen));
    await tester.pump(const Duration(seconds: 3));
    await tapText(LocaleKeys.paywall_plan_monthly.tr(), scroll: true);
    await tapText(LocaleKeys.paywall_subscribe.tr());
    await waitFor(find.byType(ScanCard));
    await shot('home-premium');

    // Recommendation: the watched series must not be suggested
    await tester.tap(find.byType(TonightCard));
    await waitFor(find.text(LocaleKeys.recommend_submit.tr()));
    await tapText(LocaleKeys.recommend_pref_thrilling.tr());
    await tapText(LocaleKeys.recommend_submit.tr());
    await waitFor(find.byType(RecommendationCard), seconds: 60);
    await shot('recommendation');
    expect(find.textContaining('Breaking'), findsNothing);
    await goBack();
    await waitFor(find.byType(ScanCard));

    // Profile: switch to English, then delete the account
    await tester.tap(find.byIcon(Icons.person_outline));
    await waitFor(find.byType(ProfileScreen));
    await shot('profile');
    await tapText(LocaleKeys.profile_language.tr(), scroll: true);
    await waitFor(find.text('English'));
    await shot('profile-language-sheet');
    await tapText('English');
    await tester.pump(const Duration(milliseconds: 600));
    await shot('profile-english');
    await tapText(LocaleKeys.profile_delete_account.tr(), scroll: true);
    await shot('profile-delete-dialog');
    await tapText(LocaleKeys.profile_delete_confirm.tr());
    await waitFor(find.byType(OnboardingScreen));
    await shot('onboarding-after-delete');
  });
}
