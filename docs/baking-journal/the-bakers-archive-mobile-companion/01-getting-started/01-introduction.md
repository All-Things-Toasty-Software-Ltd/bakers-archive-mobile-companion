---
title: "Introduction"
seo_title: "Introduction | Baking Journal"
meta_description: "What The Baker's Archive Mobile Companion is, who it is for, and how it talks to the archive site."
slug: "the-bakers-archive-mobile-companion/getting-started/introduction"
type: "page"
order: 1
---

# Introduction

The Baker's Archive Mobile Companion (version `1.0.0`) is a Flutter app published by All Things Toasty Software Ltd. It turns a Baker's Archive website into a phone-friendly recipe companion with a richer reading experience than the website alone.

The app is **not** a recipe backend. It talks directly to the same public, read-only REST API the website exposes, so every recipe you see is already public and lives on the archive site you point the app at.

## What it does

- Lists the archives published on the configured Baker's Archive site.
- Shows a searchable recipe feed across those archives.
- Opens a full recipe with ingredients, method, attribution and notes.
- Scales quantities with baker's math and a batch multiplier.
- Saves recipes locally for offline reading.
- Groups method steps into categories and can time them.
- Provides a large-text Kitchen Mode for hands-messy-with-flour baking.

## Who it is for

- **Bakers** who want a phone beside the scale instead of a browser tab.
- **Site owners** running the Odoo `bakers_archive` module who want a companion app for their readers.
- **Integrators** who want to reuse the public API and models.

## What it deliberately does not do

- No recipe editing is performed in the app.
- No server-side component of its own is shipped by the project.
- No analytics or tracking is bundled.

## Platforms

Version `1.0.0` targets Android and Web from the shared Flutter codebase, and ships a Windows runner used by the Toasty Deployer MSIX build. The same Dart code drives all three.
