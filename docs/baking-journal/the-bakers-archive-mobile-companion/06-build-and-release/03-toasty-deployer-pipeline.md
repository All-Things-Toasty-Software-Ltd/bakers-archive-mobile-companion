---
title: "Toasty Deployer Pipeline"
seo_title: "Toasty Deployer Pipeline | Baking Journal"
meta_description: "The Linux build helpers, release scripts and what a successful deployer run leaves behind."
slug: "the-bakers-archive-mobile-companion/build-and-release/toasty-deployer-pipeline"
type: "page"
order: 3
---

# Toasty Deployer Pipeline

The authoritative release path is the `All-Things-Toasty-Software-Ltd/bakers-archive-mobile-companion.sh` pipeline in `Toasty Deployer`. The Windows VM is no longer involved.

## Helper responsibilities

| Helper | Role |
| --- | --- |
| `clone-repository.sh` | HTTPS clone of the GitHub repository into `/tmp/toasty-build.*`. |
| `android-build.sh` | Linux build: locates Flutter, writes temporary `android/key.properties`, builds signed APK/AAB, verifies the APK, and writes `bakers-archive.apk` / `bakers-archive.aab`. |
| `version-check.sh` | Reads `pubspec.yaml` when present, otherwise `android/app/build.gradle.kts`. Emits `VERSION_CODE`, `VERSION_NAME`, `RELEASE_REQUIRED`. |
| `github-release.sh` | Builds a GitHub App JWT and creates/uploads the APK asset. |
| `gitlab-release.sh` | Creates/uploads an APK to the self-hosted GitLab release for `toasty-software/bakers-archive-mobile-companion`. |
| `google-play-release.py` | Creates a Play edit, uploads the AAB and attaches release notes. |

## Artifact naming

The deployer renames outputs to:

- `bakers-archive.apk`
- `bakers-archive.aab`

so the release scripts stay stable regardless of Flutter's default names.

## Idempotence

Re-running with an unchanged `versionCode` builds but does not publish. `--release` forces publishing. Nothing is committed or pushed back to this repository by the pipeline; it only reads `main`.

## GitLab authentication

`gitlab-release.sh` reads `/opt/toasty-deployer/secrets/gitlab.env`:

```bash
GITLAB_HOST=git.toastysoftware.co.uk
GITLAB_TOKEN=<api token with api and write_repository scope>
GITLAB_PROJECT=toasty-software/bakers-archive-mobile-companion # optional
GITLAB_REF=main                                            # optional
```

The token is not committed anywhere and is only available on the deployer host.

## Failure points

- **Flutter missing on the Linux builder** — the script stops with `Flutter SDK not found`.
- **Android SDK missing** — `flutter doctor` and build stop early.
- **Empty `releaseNotes.md`** — aborts with a missing/empty notes error.
- **Version code unchanged** — exits after the build with no release.
- **GitLab release already exists** — the helper refuses to overwrite an existing release.
