---
title: "Local Development & Android Builds"
seo_title: "Local Development & Android Builds | Baking Journal"
meta_description: "Common Flutter commands for running, analyzing, testing and building the Android app."
slug: "the-bakers-archive-mobile-companion/build-and-release/local-development-and-builds"
type: "page"
order: 1
---

# Local Development & Android Builds

## Daily loop

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release artifacts

```bash
flutter build apk       --release --build-name 1.0.0 --build-number 8
flutter build appbundle --release --build-name 1.0.0 --build-number 8
```

`--build-name`/`--build-number` come from `version: 1.0.0+8` in `pubspec.yaml`; you only need to pass them explicitly when packaging outside the default flow.

## Signing locally

For a local signed release, create `android/key.properties` as described in **Getting Started → Installation & Requirements**. The release build falls back to the debug keystore when the file is absent.

## Where outputs live

| Artifact | Path |
| --- | --- |
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` |

## Do not

- Do not commit `build/`, `.dart_tool/`, `android/key.properties`, keystores or passwords.
- Do not edit the generated `flutter/ephemeral/` directory.

## Android-only

The project deliberately does not ship a web or Windows target. Adding another platform is a product decision and should include the appropriate store/distribution work before it is re-enabled.
