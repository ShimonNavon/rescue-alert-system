# rescue_app

Flutter client for the Rescue Alert System. Authenticates against the Django API with
JWT access/refresh tokens and talks to the backend over HTTP.

## Prerequisites

- Flutter 3.47+ / Dart 3.13+
- Android SDK for Android builds
- Xcode + CocoaPods for iOS builds
- Network access to the backend (the committed env files point at the Tailscale host
  `ubuntu03`)

## Configuration

`.env.staging` and `.env.production` are committed because they contain no secrets:

```dotenv
ENV=staging
API_BASE_URL=http://ubuntu03:30093
MAPBOX_ACCESS_TOKEN=
```

Change `API_BASE_URL` for another environment. Set `MAPBOX_ACCESS_TOKEN` to enable the
map. The app loads the file matching `--dart-define=ENV=<staging|production>`.

## Run

```bash
flutter pub get
flutter run --dart-define=ENV=staging
```

## Tests

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

## Authentication

- Sign-up requires the server's `REGISTRATION_INVITE_CODE`.
- Login calls `POST /api/token/`; access and refresh tokens are stored in secure storage.
- Expired access tokens are refreshed automatically on a 401.
- Logout blacklists the refresh token and clears local storage.
- Push notifications are intentionally disabled until the FCM replacement (ntfy /
  UnifiedPush) is deployed; `NotificationService` is a no-op stub.

## Platform notes

- Android has `INTERNET` and cleartext HTTP enabled for the Tailscale URL. Use HTTPS
  and remove `usesCleartextTraffic` before a public release.
- iOS App Transport Security blocks plain HTTP by default. Add an ATS exception for a
  staging host or serve the API over HTTPS.
- The Android SDK is not installed on the current build machine; an APK has not been
  produced yet.
