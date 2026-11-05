---
title: "Troubleshooting"
seo_title: "Troubleshooting | Baking Journal"
meta_description: "Common symptoms, from an empty feed to a failed store submission, and where to look first."
slug: "the-bakers-archive-mobile-companion/operations/troubleshooting"
type: "page"
order: 1
---

# Troubleshooting

## Feed is empty

1. Check the badge. Red means the probe is failing before the list loads.
2. Confirm the site is an archive host, not an Odoo hosting page (`/web/login` returning HTML is fine; `/archive/api/v1/archives` must return JSON).
3. If the feed populates only after tapping a single archive chip, the merge step saw archives but their recipe pages returned no items — check they are published and have recipes.

## “Baker's Archive module not found”

The base Odoo probe succeeded but no `api_version` was echoed. Possible causes:

- `bakers_archive` not installed or not updated.
- The site caches the API via a CDN and is serving an old 404.
- A reverse proxy strips `api_version` from dynamic JSON (rare).

## Detail screen stuck on “Baking recipe details…”

- Confirm you have network. The screen does not refresh itself.
- If you previously favourited the recipe, the offline copy opens immediately; if this succeeds you have no network but a valid cache.
- If neither succeeds, pull down / retry while watching `flutter run --verbose` for a timeout string.

## Favourite heart does nothing

The app fetches the full recipe before toggling to guarantee the offline copy is complete. On a metered or absent connection this fetch fails, so the toggle is rejected rather than saving a broken stub.

## Kitchen Mode timer shows zeros

`Instruction.timeMinutes` must be > 0 — a blank time column means no timer control is shown. The step timer starts paused and never ticks on its own after you visit the next/previous step.

## Build fails with `Unable to locate Android SDK`

Run `flutter doctor --android-licenses` and ensure `ANDROID_HOME` is exported before the first `flutter build`.

## MSIX rejected with `0x800700C1` or publisher mismatch

The PFX subject does not match `msix_config.publisher`. Export the certificate and correct `publisher` in `pubspec.yaml`, or use the same PFX as the store reservation.
