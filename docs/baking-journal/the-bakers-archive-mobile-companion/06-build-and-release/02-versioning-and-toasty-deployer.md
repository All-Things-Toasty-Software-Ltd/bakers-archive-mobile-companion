---
title: "Versioning & Toasty Deployer"
seo_title: "Versioning & Toasty Deployer | Baking Journal"
meta_description: "How pubspec versioning, releaseNotes.md and the deployer pipeline fit together."
slug: "the-bakers-archive-mobile-companion/build-and-release/versioning-and-toasty-deployer"
type: "page"
order: 2
---

# Versioning & Toasty Deployer

Releases are triggered by push to `main` and by the Toasty Deployer runner, not by manual store uploads.

## The one-line version source of truth

`pubspec.yaml`:

```yaml
version: 1.0.0+6
```

`1.0.0` becomes `versionName` / `package.version`; `6` becomes `versionCode` / MSIX `1.0.0.0`. The Android build reads it through `flutter.versionCode/Name`, so the deployer only needs to parse the pubspec.

## releaseNotes.md

Every release must update `releaseNotes.md` in the repository root. It is read verbatim for:

- the GitHub release body,
- the Google Play release notes (via `google-play-release.py`),
- the Microsoft Store submission (via `msstore publish`).

Empty or missing notes abort the release before anything is uploaded.

## Deployer sequence

1. Clone `main` from GitHub.
2. Build on the Windows builder with `flutter build apk`, `flutter build appbundle` and `flutter build windows`.
3. Verify `bakers-archive.apk`, `bakers-archive.aab`, `bakers-archive.msix` exist.
4. Run `version-check.sh`; if the build number did not change, stop after a successful build (no release).
5. If it changed (or `--release` was passed), create the GitHub release, push the AAB to Google Play and submit the MSIX to the Microsoft Store.

See **Build & Release → Toasty Deployer** for the artifact mapping and **Build & Release → Windows MSIX Packaging** for the runner specifics.
