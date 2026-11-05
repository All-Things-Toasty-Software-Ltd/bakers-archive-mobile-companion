---
title: "Toasty Deployer Pipeline"
seo_title: "Toasty Deployer Pipeline | Baking Journal"
meta_description: "The exact helper scripts involved, what they check and what a successful run leaves behind."
slug: "the-bakers-archive-mobile-companion/build-and-release/toasty-deployer-pipeline"
type: "page"
order: 3
---

# Toasty Deployer Pipeline

The authoritative release path is the `All-Things-Toasty-Software-Ltd/bakers-archive-mobile-companion.sh` pipeline in `Toasty Deployer`.

## Helper responsibilities

| Helper | Role |
| --- | --- |
| `clone-repository.sh` | HTTPS clone of the GitHub repository into `/tmp/toasty-build.*`. |
| `version-check.sh` | Reads `pubspec.yaml` when present, otherwise `android/app/build.gradle.kts`. Emits `VERSION_CODE`, `VERSION_NAME`, `RELEASE_REQUIRED`. |
| `windows-build.ps1` | rsyncs the checkout to the Windows VM, builds with Flutter, writes `key.properties`, runs `msix:create`, copies artifacts back. |
| `github-release.sh` | Builds a GitHub App JWT and creates/uploads the release assets (APK + MSIX). |
| `google-play-release.py` | Creates a Play edit, uploads the AAB and attaches release notes. |
| `microsoft-store-release.sh` | Publishes the MSIX with `dbus-run-session -- msstore publish`. |

## Artifact naming

The deployer renames outputs to:

- `bakers-archive.apk`
- `bakers-archive.aab`
- `bakers-archive.msix`

so the release scripts stay stable regardless of Flutter's default names.

## Idempotence

Re-running with an unchanged `versionCode` builds but does not publish. `--release` forces publishing. Nothing is committed or pushed back to this repository by the pipeline; it only reads `main`.

## Failure points

- **Flutter missing on the builder** — script stops with `Flutter SDK not found`.
- **Mismatched MSIX publisher** — `SignTool` derives the `publisher` from the PFX; a store certificate whose subject differs from `msix_config.publisher` fails signature validation.
- **Empty `releaseNotes.md`** — aborts with a missing/empty notes error.
- **Changed versionCode missing from the previous tag** — `version-check.sh` compares against `HEAD^`; if the pubspec build number was not bumped the run exits cleanly after printing `Build completed, but no release will be created.`

## Ownership

The deployer and helpers are in `deployer-scripts`; the app never self-publishes. All releases remain manual-invocable but automatic in outcome.
