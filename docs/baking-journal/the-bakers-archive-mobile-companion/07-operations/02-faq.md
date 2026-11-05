---
title: "FAQ"
seo_title: "FAQ | Baking Journal"
meta_description: "Short answers for users, maintainers and recipe publishers."
slug: "the-bakers-archive-mobile-companion/operations/faq"
type: "page"
order: 2
---

# FAQ

## Does the app store my Odoo password?

Only until you sign out. The password text field is backed by memory only; what is persisted is the resulting session payload plus the user profile.

## Can I use this with an archive behind Cloudflare Access?

No. The app expects unauthenticated public access to the archive JSON endpoints. Put the app behind the same token if you intend to serve archive APIs publicly; Access headers cannot be injected today.

## Why are quantities not perfectly pretty at 1.5×?

Quantities are rounded to one decimal after scaling. `1.5 × 2 tsp` is shown as `3 tsp`; `1.5 × 2.5 g` becomes `3.8 g` because of float handling by design.

## Why does the Saved tab show nothing even though I have favourites?

You signed in on a fresh device. Favourites are device-local; sign-in does not sync them.

## How do I publish my own archive into the app?

Install `bakers_archive`, publish an archive and its recipes, expose it on a host that answers `/archive/api/v1/archives` with `{ "api_version": "v1", ... }`, then add that host in **Settings**.

## How do we release?

Bump `version:` in `pubspec.yaml`, write `releaseNotes.md`, push to `main` and invoke `Toasty Deployer`. See **Build & Release**.

## Is the source public?

The module itself is LGPL/OPL-licensed per the parent repository. The companion is All Things Toasty Software Ltd proprietary-derived; check the repository headers before reusing code or icons.

## Why did the Kotlin app disappear?

The 0.x releases were implemented as Compose Multiplatform. Version `1.0.0` completes the migration to the Flutter design; the legacy Kotlin targets are retained in history only.
