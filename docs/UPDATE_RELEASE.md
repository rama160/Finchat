# Update & Release Guide

## Release source

FinChat uses GitHub Releases as the canonical public release source for the update checker.

Repository: `rama160/Finchat`

The application asks GitHub for the latest published release. Draft and prerelease versions are not used by the latest-release endpoint.

## App version

Keep these values aligned:
- `pubspec.yaml` → `version: major.minor.patch+build`
- `lib/core/constants/app_constants.dart` → `appVersion`
- GitHub Release tag → `vmajor.minor.patch`

The build number is local to the Flutter package; update comparison currently uses `major.minor.patch`.

## Release workflow

GitHub Actions:
1. checkout;
2. install Flutter stable;
3. `flutter pub get`;
4. `flutter analyze`;
5. `flutter test`;
6. create Android platform if missing;
7. apply Android security/speech configuration;
8. `flutter build apk --release`;
9. publish APK to GitHub Release.

## In-app update behavior

Settings → Periksa pembaruan:
- no newer release → show current version;
- newer release → show release version and open the GitHub release page;
- network/API failure → show an error without changing local data.

The checker does not silently install an APK.

## Data safety

Application updates must never delete the SQLite database. If a future release changes the schema, increment `FinChatDatabaseSchema.version` and add an explicit non-destructive `onUpgrade` migration.

Before a production release that changes schema:
- test upgrade from the previous release database;
- test backup before upgrade;
- test restore after upgrade;
- test rollback/recovery procedure where applicable.

## Current limitation

Direct in-app APK installation is intentionally deferred. Distribution strategy (GitHub APK, Play Store, or managed enterprise distribution) must be chosen before implementing installation-specific code.
