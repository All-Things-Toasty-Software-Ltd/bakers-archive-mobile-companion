---
title: "Storage & Offline Cache"
seo_title: "Storage & Offline Cache | Baking Journal"
meta_description: "shared_preferences keys, full-recipe caching and the offline fallback path."
slug: "the-bakers-archive-mobile-companion/app-architecture/storage-and-offline-cache"
type: "page"
order: 3
---

# Storage & Offline Cache

Local persistence is handled by `StorageService` in `lib/data/services/storage_service.dart`, backed by `shared_preferences`. There is one singleton instance created in `main()` and passed through the provider tree.

## Keys

| Key | Contents |
| --- | --- |
| `bakers_server_url` | Last used host. |
| `bakers_database` | Optional database override. |
| `bakers_theme_mode` | `warm_crust`, `dark_toast` or `system`. |
| `bakers_user_session` | `OdooUser` JSON. |
| `bakers_local_favorites` | String list of favourite recipe ids, newest first. |
| `bakers_favorites_data_cache_<id>` | Full `RecipeDetail` JSON for offline reading/export. |

## What gets cached

Only user-selected favourites are cached in full. The app does **not** pre-cache the archive feed. A favourite stores:

- flattened recipe fields (`id`, `name`, `teaser`, `publishedDate`, `visits`, `archiveId/Name`, attribution, source/license/country),
- ingredients (including extracted baker percentage),
- instructions with category and timing,
- tags,
- hero image URL and canonical web URL.

`RecipeDetail.toJson()/fromJson()` round-trips this copy without contacting the site.

## Offline fallback

`RecipeDetailProvider.loadRecipe()` first tries the live API with `depth=3`. On any failure it asks `StorageService.getOfflineRecipeDetail()` for a cached copy. When present the screen shows an amber banner:

> Viewing saved offline copy from your Favorites.

If no cache exists, the normal error state with a retry button is shown.

## Clearing

**Settings → Offline Storage → Clear All** removes the id list and every `bakers_favorites_data_cache_*` payload. It does not sign you out or change the server.
