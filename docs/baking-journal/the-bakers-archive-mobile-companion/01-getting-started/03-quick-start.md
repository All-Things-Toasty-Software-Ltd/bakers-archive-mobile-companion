---
title: "Quick Start"
seo_title: "Quick Start | Baking Journal"
meta_description: "Run the app against a Baker's Archive site in a few commands, and point it at your own server."
slug: "the-bakers-archive-mobile-companion/getting-started/quick-start"
type: "page"
order: 3
---

# Quick Start

## Run it

```bash
flutter run
```

Choose an Android device or emulator when prompted. On the first launch the app targets the default Baker's Archive site configured in `lib/core/constants/app_constants.dart`:

```dart
static const String defaultServerUrl = "https://austinatts.co.uk";
```

## Point it at your own site

Open **Settings** → **Odoo Server & Deployment** → enter your archive host → **Test Connection**. If the archive module is correctly installed the badge in the top bar turns green and the feed refreshes.

The app normalises host input:

- A bare host (`example.com`) becomes `https://example.com`.
- Trailing slashes are trimmed.
- HTTP is accepted if you explicitly enter it, useful on a local Odoo.

## What you should see

1. **Explore** — a feed of recipe cards from every archive on the site.
2. **Saved** — empty at first; tap the red heart on a recipe to save it offline.
3. **Settings** — server, theme and account controls.

## Troubleshooting the connection

- **“Baker's Archive module not found”** — the JSON-RPC probe reached Odoo but `/archive/api/v1/archives` did not return `api_version: v1`. Check that `bakers_archive` is installed and the site's `list_db` setting.
- **Timeout** — the default probe is 8–12 seconds. Reverse proxies and Cloudflare sometimes delay first hits; try once more.
- **Empty feed** — confirm the archive is published and has published recipes.

See **Operations → Troubleshooting** for the full matrix.
