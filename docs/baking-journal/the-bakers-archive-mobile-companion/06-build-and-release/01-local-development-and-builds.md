---
title: "Local Development & Builds"
seo_title: "Local Development & Builds | Baking Journal"
meta_description: "Common flutter commands for run, analyze, pub, apk, appbundle, web and windows."
slug: "the-bakers-archive-mobile-companion/build-and-release/local-development-and-builds"
type: "page"
order: 1
---

# Local Development & Builds

## Daily loop

```bash
flutter pub get
flutter analyze
flutter run
```

For tests:

```bash
flutter test
```

## Release artifacts

```bash
flutter build apk      --release --build-name 1.0.0 --build-number 6
flutter build appbundle --release --build-name 1.0.0 --build-number 6
flutter build web      --release
flutter build windows  --release
```

`--build-name`/`--build-number` come from `version: 1.0.0+6` in `pubspec.yaml`; you only need to pass them explicitly when packaging outside the default flow.

## Windows packages

After `flutter build windows --release` the output lands under `build/windows/x64/runner/Release/`. The `msix` package consumes that directory:

```bash
dart run msix:create \
  --build-windows false \
  --certificate-path C:/certs/msix-signing.pfx \
  --certificate-password "<password>" \
  --output-path C:/artifacts
```

It renders `build/windows/.../bakers_archive.msix` from the `msix_config:` block in `pubspec.yaml`.

## Where outputs live

| Artifact | Path |
| --- | --- |
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Web | `build/web/` |
| Windows runner | `build/windows/x64/runner/Release/` |
| MSIX | `build/windows/msix/` or the `--output-path` supplied |

## Do not

- Do not commit `build/`, `.dart_tool/`, `android/key.properties`, keystores or PFX files.
- Do not edit the generated `flutter/ephemeral/` directory.
