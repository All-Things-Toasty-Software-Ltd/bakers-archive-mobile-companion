---
title: "Versioning & Toasty Deployer"
seo_title: "Versioning & Toasty Deployer | Baking Journal"
meta_description: "How pubspec versioning, releaseNotes.md and the Linux deployer pipeline fit together."
slug: "the-bakers-archive-mobile-companion/build-and-release/versioning-and-toasty-deployer"
type: "page"
order: 2
---

# Versioning & Toasty Deployer

Releases are triggered by push to `main` and by the Toasty Deployer runner, not by manual store uploads.

## The one-line version source of truth

`pubspec.yaml`:

```yaml
version: 1.0.0+8
```

`1.0.0` becomes `versionName`; `8` becomes `versionCode`. The Android build reads them through `flutter.versionCode/flutter.versionName`, so the deployer only needs to parse the pubspec.

## releaseNotes.md

Every release must update `releaseNotes.md` in the repository root. It is read verbatim for:

- the GitHub release body,
- the GitLab release description,
- the Google Play release notes (via `google-play-release.py`).

Empty or missing notes abort the release before anything is uploaded.

## Deployer sequence

1. Clone `main` from GitHub into a temporary Linux workspace.
2. Build with Flutter on the Linux host: `flutter build apk` and `flutter build appbundle`.
3. Verify `bakers-archive.apk` and `bakers-archive.aab` exist and the APK passes `apksigner`.
4. Run `version-check.sh`; if the build number did not change, stop after a successful build (no release).
5. If it changed (or `--release` was passed), create:
   - a GitHub release with the APK,
   - a GitLab release with the APK,
   - a Google Play rollout with the AAB.

See **Build & Release → Toasty Deployer Pipeline** for the exact helper mapping.
