---
title: "Installation & Requirements"
seo_title: "Installation & Requirements | Baking Journal"
meta_description: "The Flutter SDK, Android toolchain, signing material and the repository you need before building."
slug: "the-bakers-archive-mobile-companion/getting-started/installation-and-requirements"
type: "page"
order: 2
---

# Installation & Requirements

## Prerequisites

| Item | Used for |
| --- | --- |
| Linux or macOS | Building the Android APK/AAB. Toasty Deployer builds on Linux. |
| Flutter SDK (stable) with Dart 3 | Building and running the Android app. |
| Android SDK with recent build-tools | Assembling, signing and verifying the APK/AAB. |
| JDK 21 | Gradle and the Android toolchain on Debian Trixie (Java 17 bytecode is still targeted). |
| `git` / `jj` | Working with the repository. |

The app was developed against Flutter channels whose `flutter --version` reports Dart `>= 3.3.0` and `< 4.0.0`, matching `pubspec.yaml`.

## Clone

```bash
git clone https://github.com/All-Things-Toasty-Software-Ltd/bakers-archive-mobile-companion.git
cd bakers-archive-mobile-companion
```

## Install dependencies

```bash
flutter pub get
```

This resolves the Flutter plugins (`provider`, `shared_preferences`, `http`, `cached_network_image`, `google_fonts`, `share_plus`, `url_launcher`, `font_awesome_flutter`).

## Android signing

Local development builds fall back to the debug keystore. Release builds from Toasty Deployer write `android/key.properties` from CI secrets:

```properties
storeFile=/path/to/android-release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

The deployer removes the file after the build. Never commit `key.properties` or the keystore.

## Release stores

The Linux release pipeline publishes the same APK/AAB to:

- GitHub releases,
- Toasty Software's self-hosted GitLab releases,
- Google Play internal/production track, selected through `PLAY_TRACK`.
