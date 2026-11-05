---
title: "Platform Services"
seo_title: "Platform Services | Baking Journal"
meta_description: "Networking, caching, sharing, link handling and images across Android, Windows and web."
slug: "the-bakers-archive-mobile-companion/app-architecture/platform-services"
type: "page"
order: 4
---

# Platform Services

## HTTP client

All API traffic goes through `package:http` inside `BakersApiService` and `OdooAuthService`. Requests are not abstracted behind an interceptor chain; each call sites sets its own timeout:

| Operation | Timeout |
| --- | --- |
| Connection probe | 8 s |
| Archive list | 10 s |
| Archive recipe page | 10 s |
| Recipe detail | 12 s |
| Odoo login probe | 6 s |

Responses are decoded from raw `bodyBytes` as UTF-8 to tolerate non-ASCII bread names and curly apostrophes returned by some encodings.

## Images

`cached_network_image` renders recipe covers and avatars. Caches land in Flutter's temp/cache directory. When the URL 404s or the device is offline, each consumer degrades to a bread-slice placeholder instead of a broken-image icon.

## Sharing

`share_plus` is used by the recipe detail app-bar share button. The share text contains the recipe title, teaser (when present) and canonical `$server/archive/recipe/<id>` URL.

## External links

`url_launcher` opens Toasty Software's website, Austin ATTS, and the mobile-companion GitHub repository from Settings → About with `LaunchMode.externalApplication`.

## Platform notes

- **Android** — release signing is driven by `android/key.properties` (see Build & Release).
- **Windows** — the MSIX runner sets `internetClient` capability and stores config in `%APPDATA%`.
- **Web** — the same code runs from the `web/` entry; CORS must be allowed by the Odoo/website serving the API.

## Failure philosophy

No platform-specific code is expected to throw across the boundary. Every service call returns a `Future` that either resolves to a result object/model or throws, and providers are responsible for converting that into UI state.
