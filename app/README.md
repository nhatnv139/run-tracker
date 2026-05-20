# RunVie

Vietnamese-first running tracker. Cross-platform Flutter app targeting iOS and Android.

## Tech stack

- Flutter 3.27+ / Dart 3.5+
- Riverpod 2 (state)
- go_router 14 (navigation)
- Supabase (backend, auth, postgres)
- Geolocator + flutter_background_service (GPS / background)
- Drift (sqlite local) + Hive (key-value cache)
- Freezed + json_serializable (models)

## Setup

### Prerequisites

1. Install Flutter SDK 3.27+ from <https://docs.flutter.dev/get-started/install/windows>
2. Run `flutter doctor` and resolve issues.
3. Android Studio with Android SDK for Android builds.
4. For iOS builds: use Codemagic / GitHub Actions macOS runner (cannot build iOS on Windows).

### First run

```bash
cd D:/dev/run-tracker/app
cp .env.example .env
# edit .env with real Supabase URL/key
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Project init (if regenerating)

If the project was created manually (no Flutter CLI was available at scaffold time), regenerate native platform folders:

```bash
flutter create --org com.runvie --platforms ios,android --project-name runvie .
flutter pub get
```

This will populate `android/` and `ios/` while preserving `lib/`, `pubspec.yaml`, etc.

### Codegen

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Build

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (must run on macOS / Codemagic)
flutter build ios --release
```

## iOS build via Codemagic

Push to `main` and Codemagic picks up `codemagic.yaml` (to be added). It signs and uploads to TestFlight.

## Folder structure

```
lib/
  main.dart                # bootstrap (env, Hive, Supabase)
  app.dart                 # MaterialApp.router
  core/                    # theme, router, env, constants
  features/                # onboarding, auth, home, run, activity, plan, profile, badges, social
  services/                # location, pedometer, background, supabase, calorie, voice_coach
  data/                    # repositories, local (drift), remote
  shared/                  # widgets, extensions, utils
```

## Notes

- No web / desktop targets.
- All TTS strings are Vietnamese-first.
- Background GPS is OFF by default until user grants `always` permission.
- Voice coach uses on-device TTS (placeholder service in MVP).
