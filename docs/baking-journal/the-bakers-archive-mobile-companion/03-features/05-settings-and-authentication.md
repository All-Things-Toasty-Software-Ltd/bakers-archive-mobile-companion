---
title: "Settings & Authentication"
seo_title: "Settings & Authentication | Baking Journal"
meta_description: "Server URL, test connection, single-database handling, Odoo sign-in, sign-out, offline storage and About links."
slug: "the-bakers-archive-mobile-companion/features/settings-and-authentication"
type: "page"
order: 5
---

# Settings & Authentication

The Settings tab is split into labelled sections. The section header is typeset in tracked-out amber caps.

## Odoo server & deployment

Edit the host URL and tap the trailing check circle or the button to apply it. The app normalises the value, persists it and re-probes in one step. When the app boots it also probes the stored URL so the badge is not stale.

The app explains single-database deployments inline: hosts with `list_db = False` (like austinatts.co.uk) do not require you to pick a database — session authentication is used instead.

The connection result panel shows:

- latency in milliseconds,
- `Found N archives.` on success,
- base Odoo version when the archive module is missing,
- raw errors otherwise.

## Odoo user account

Browsing is public. Signing in is only required to reach internal pages or for the archive owner. The screen either shows the signed-in card (avatar, name, username, administrator badge, sign-out) or the guest card with **Sign in as Admin / Odoo User**.

Authentication tries two paths:

1. The web login flow: GET `/web/login` to obtain the session cookie and `csrf_token`, POST the credentials back, then POST `/web/session/get_session_info`.
2. A JSON-RPC fallback (`/web/session/authenticate`) once the database is known or auto-probed.

On failure the snackbar shows the provider message rather than a stack trace. Password handling stays inside `OdooAuthService`; the UI never holds more than the text field contents.

## Appearance

Radio group for the three theme modes (`Warm Crust`, `Dark Toast`, `System Default`). Changes are persisted immediately.

## Offline storage

Shows how many recipes are cached and a red **Clear All** when non-empty.

## About

App name, version read from `AppConstants.appVersion`, and launcher buttons for Toasty Software, Austin ATTS and the companion's GitHub repository.
