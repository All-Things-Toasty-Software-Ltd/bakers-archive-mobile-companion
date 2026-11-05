---
title: "Installation & Requirements"
seo_title: "Installation & Requirements | Baking Journal"
meta_description: "The Flutter SDK, Android/Windows toolchain, signing material and the repository you need before building."
slug: "the-bakers-archive-mobile-companion/getting-started/installation-and-requirements"
type: "page"
order: 2
---

# Installation & Requirements

## Prerequisites

| Item | Used for |
| --- | --- |
| Flutter SDK (stable) with Dart 3 | Building the Android APK/AAB, web build and Windows runner. |
| Android SDK with recent build-tools | Assembling and signing the APK and AAB. |
| JDK 17 | Gradle and the Android toolchain. |
| Visual Studio with the desktop C++ workload | Windows runner used for the MSIX. |
| `msix` Dart package (`dev_dependencies`) | Packaging the Windows build into an MSIX. |
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

This resolves the Flutter plugins (`provider`, `shared_preferences`, `http`, `cached_network_image`, `google_fonts`, `share_plus`, `url_launcher`, `font_awesome_flutter`) and the `msix` packager used by the Windows release.

## Android signing

Local development builds fall back to the debug keystore. Release builds from Toasty Deployer read `android/key.properties`:

```properties
storeFile=/path/to/android-release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

The deployer writes this file during the build and removes it afterwards as part of the temporary workspace cleanup. Never commit `key.properties` or the keystore.

## Windows / MSIX signing

The MSIX manifest is produced by the `msix` package from `msix_config:` in `pubspec.yaml`. The signing certificate is supplied at packaging time with `--certificate-path` and `--certificate-password`, or the build falls back to the package's test certificate. Toasty Deployer uses the production `msstore` certificate.
