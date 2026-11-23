# Snapwatch

**Snap a screenshot of a film or series, let AI recognise it and pick what to watch tonight.**

## The idea

We see films and series everywhere: an Instagram post, a trailer a friend sends, a poster in a story. We take a screenshot, and it disappears in the gallery. Snapwatch turns that screenshot into a watchlist entry: AI recognises the title from the image and fills in the year, genre, runtime, director, plot and where to watch it. When the evening comes, the user asks "What should we watch tonight?" and AI picks the best title **from their own list** for their mood. It is built for people who save more than they watch, and they pay for it because Premium removes the scan limit and unlocks the personal "tonight" picks.

Snapwatch is the first module of a bigger idea (MOMENTBOX: save anything you see, AI reminds you at the right moment). For this study case it is kept to one clear purpose: films and series.

## Screens and flow

| Screen | What it does |
|---|---|
| Splash | Loading bar, then routes to onboarding (first launch) or home. |
| Onboarding | 4 pages: the problem, how it works, favourite genres, name. On the last page a guest account is created in the background and the paywall opens. |
| Paywall (static) | Free vs Premium table, weekly / yearly / monthly plans, subscribe, restore, terms and privacy links. The close button appears after 3 seconds. |
| Home (no navigation bar) | Scan a screenshot, "What should we watch tonight?" (Premium), watchlist and watched tabs. |
| Scan → Result | Scanning progress over the picked image, then the AI result: title, year, runtime/seasons, genres, director, plot, where to watch, add to list / mark as watched. |
| Recommendation | Mood filters and a free-text request; up to 3 picks from the watchlist with a reason each. |
| Profile | Guest account, subscription status, language (Turkish / English), favourite genres, terms, privacy, reset. |

**Free vs Premium:** free users get 3 successful scans (a failed scan does not count). Premium gives unlimited scans and the "tonight" picks. Buying is simulated; no real payment is made.

## Architecture

Three layers with one rule: **screen → cubit → repository → service**. A screen never talks to a service, and a cubit never talks to Firebase directly.

```
lib/
  main_dev.dart / main_prod.dart   entry points, both call main_common.dart
  main_common.dart                 Firebase, App Check, localisation, storage, runApp
  app/                             app widget, router (go_router), theme, environment
  core/                            errors, localisation helpers, links, shared widgets
  data/
    models/                        plain Dart models with hand-written fromJson/toJson
    services/                      talk to the outside world: Gemini, Firebase Auth, SharedPreferences
    repositories/                  app rules on top of services: free scan limit, watchlist, errors
  features/<screen>/               <screen>_screen.dart, <screen>_cubit.dart, <screen>_state.dart, widgets/
```

- **Services** only know how to call something (Gemini, Firebase Auth, SharedPreferences).
- **Repositories** hold the app's rules: the 3 free scans, no duplicate titles in the list, turning Firebase / network errors into one `AppException` type, and checking the AI's answers.
- **Cubits** hold screen state and call repositories. They are created with the screen (`BlocProvider`), so their state is gone when the screen closes.
- Repositories are created once at the top of the app (`MultiRepositoryProvider`) and read with `context.read<...>()`. No service locator package is needed for an app this size.
- **dev / prod:** `main_dev.dart` shows a DEV banner and the debug banner; `main_prod.dart` shows neither. Both share `main_common.dart`.

### State management: flutter_bloc (Cubit)

Cubit was chosen because state changes are explicit (`emit(...)`), it is easy to test and I use it in production projects. The state shape follows what the screen needs:

| State shape | Used for | Why |
|---|---|---|
| `sealed class` | Splash, Scan | A process with clear steps (idle → in progress → success / failure). The UI uses `switch`, and the compiler warns if a case is missed. |
| One class + `copyWith` | Onboarding, Paywall, Recommendation | Form-like screens where several fields change independently. |
| A single value | Detail (`WatchStatus?`) | The only thing that changes is the title's place in the list. |

Pure UI state (current onboarding page, selected tab, the paywall's 3-second timer) stays in the widget's own `State`, not in a cubit.

## AI integration

AI is the core of the app, used for two things through **Gemini (Firebase AI Logic)**:

1. **Recognising the title from an image.** The screenshot is resized (max 1600 px) and sent with a prompt and a **JSON schema**, so the answer is structured data, not free text. The model is told to set `isMediaTitle: false` instead of guessing; the app then shows "I couldn't find a film or series in this image" and the free scan is not used.
2. **"What should we watch tonight?"** The model gets the user's **to-watch** list as a numbered list, their favourite genres and their mood, and returns picks by number with a one-sentence reason. Watched titles are never sent, so they can never be recommended.

**The AI's output is checked in code, not trusted blindly:**
- "Films only / Series only" is applied in code before the request.
- Pick numbers that are not in the list, or repeated, are dropped, so the model cannot add a title that is not in the user's list.
- Empty strings are treated as missing fields.
- Answers come in the app's language (Turkish or English).

**Model choice:** `gemini-3.5-flash-lite` (stable, no shutdown date). `gemini-3.8-flash` did not answer on this project during testing, so the faster lite model was measured and chosen; recognition takes a few seconds.

**Security:** the Gemini API key is not in the app; requests go through Firebase AI Logic and are protected by **Firebase App Check** (required for AI Logic since November 2026). Release builds use Play Integrity / App Attest; development builds use a registered debug token.

## Packages

| Package | Why |
|---|---|
| `flutter_bloc` | State management (Cubit) and dependency providers. |
| `go_router` | Routing; route names are constants in `AppRoutes`. |
| `firebase_core`, `firebase_ai` | Gemini through Firebase AI Logic (no API key in the app). |
| `firebase_app_check` | Required by Firebase AI Logic; protects the AI quota. |
| `firebase_auth` | Anonymous guest account, ready to link to Google / Apple later. |
| `easy_localization` | Turkish (default) and English, switchable in Profile; keys are generated as `LocaleKeys`. |
| `shared_preferences` | Profile, plan, scan count and watchlist on the device. |
| `image_picker` | Picking the screenshot from the gallery. |
| `url_launcher` | Streaming platform links, terms and privacy. |
| `integration_test`, `flutter_driver` (dev) | End-to-end test of the whole flow with screenshots. |

Deliberately not used: code generation (freezed / json_serializable), get_it / injectable and a use-case layer. They would add files without adding value at this size.

Fonts (Poppins, Cormorant Garamond) are bundled under `assets/fonts` (SIL Open Font License).

## Getting started

Requirements: Flutter **3.47.1** (stable), Xcode for iOS, Android SDK for Android.

```bash
flutter pub get
```

**App Check debug token.** The Firebase config files are in the repo, but Firebase AI Logic only answers apps that pass App Check. On simulators, emulators and local builds this needs a debug token:

1. Copy `config/app_check.example.json` to `config/app_check.json` (git-ignored).
2. Put a debug token for each platform in it and register the same tokens in Firebase Console → App Check → Apps → Manage debug tokens.

Run:

```bash
flutter run -t lib/main_dev.dart  --dart-define-from-file=config/app_check.json
flutter run -t lib/main_prod.dart --dart-define-from-file=config/app_check.json
```

After adding text to `assets/translations/*.json`, regenerate the keys:

```bash
dart run easy_localization:generate -S assets/translations -s tr.json -f keys -O lib/core/l10n -o locale_keys.g.dart
```

## Testing

`integration_test/app_flow_test.dart` runs the whole app on a simulator or device with the real Firebase and Gemini. It goes through onboarding, the paywall (restore and close), scans a film poster, a series poster and a non-media image, marks a title as watched, buys a plan, checks that the watched title is **not** recommended, switches the language and resets the app. It saves a screenshot of every step to `build/screenshots/`.

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart \
  --dart-define-from-file=config/app_check.json -d <device-id>
```

The system gallery picker cannot be driven by a test, so the test opens the scan screen with sample images from `integration_test/sample_images.dart`. These are simple generated posters, not real artwork. The test passes on an Android emulator and an iOS simulator.

## Known limitations and next steps

- **Where to watch** comes from the AI and can be wrong or out of date; the screen says so, and offers a web search when no platform is known. Next step: real availability and posters from TMDB (JustWatch data).
- The paywall is static; the store is simulated in `SubscriptionRepository`. Only that file changes when RevenueCat or `in_app_purchase` is added.
- Share sheet ("Share to Snapwatch" from Instagram) instead of picking from the gallery.
- Google / Apple sign-in linked to the guest account, and cloud sync of the watchlist.

## AI tools used during development

This project was built with **Claude Code** (Anthropic) as a coding assistant. I made the product, flow and architecture decisions step by step, reviewed every change and tested the app on simulators and on my own phone. The in-app AI features use Google Gemini, as described above.
