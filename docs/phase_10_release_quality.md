# Phase 10 — Release Quality

## Implemented

- Removed the unreachable X Store catalog and legacy API authentication/password-reset source.
- Replaced X Store display names on Android, iOS, Web, Windows, and Linux without inventing new bundle IDs.
- Connected catalog `learnerEnabled` to multi-pack local loading with validation and cross-pack ID collision rejection.
- Added user-facing progress reset and authenticated account deletion.
- Added owner-only Firestore delete rules required for privacy reset and account deletion while keeping attempts non-updateable.
- Removed an unused legacy object-storage uploader, hard-coded credentials, token logging, and the simulated session cache. Previously exposed provider credentials must be revoked outside the repository.
- Replaced placeholder notification-channel identifiers and stopped logging FCM tokens or message payload data.
- Documented privacy, retention, content seeding, curriculum evidence, and release constraints.

## Release gates that remain external

- A qualified grammar specialist must review every lesson, exercise, parsed example, and analysis sample before changing its status to `approved`.
- Complete Egyptian curriculum coverage must be verified against current official sources in separately reviewed batches.
- Store signing, production Firebase project ownership, privacy contact details, and store-listing declarations require the product owner's real release credentials and legal information.
- Bundle-ID migration is intentionally not performed without an explicit identifier and Firebase migration decision.

The application must not be described as fully curriculum-approved while these external gates remain open.

## Verification snapshot — 2026-08-04

- `dart format .`: executed and the resulting changes were reviewed.
- `flutter analyze`: passed with no issues.
- `flutter test`: 67 tests passed.
- Firestore Emulator rules: 13 tests passed.
- Web debug/release compilation: passed.
- Android debug APK: passed at `build/app/outputs/flutter-apk/app-debug.apk`.
- iOS no-codesign build: blocked before compilation because the local CocoaPods lock references Firebase iOS SDK 12.13.0 while the resolved FlutterFire packages require 12.17.0. The compatible pod download was started but cancelled after the Firebase SDK Git clone progressed too slowly for the available execution window.
- macOS build: not attempted after the iOS pod download issue because it uses the same Firebase pod source and the workstation had only about 5.5 GB free.
- Windows and Linux native builds require their matching host/CI environments.

The iOS/macOS entries are environment/dependency-verification work, not evidence of a Dart application regression. Run the compatible CocoaPods update on a stable connection, then rebuild both Apple targets before release.
