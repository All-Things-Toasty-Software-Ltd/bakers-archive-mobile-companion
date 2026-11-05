---
title: "Favourites & Offline Recipes"
seo_title: "Favourites & Offline Recipes | Baking Journal"
meta_description: "How local favourites are stored, listed, filtered, removed and served offline."
slug: "the-bakers-archive-mobile-companion/features/favourites-and-offline-recipes"
type: "page"
order: 3
---

# Favourites & Offline Recipes

Favourites are intentionally account-less. They live on the device, survive restarts and require no Odoo session.

## Saving a recipe

Any recipe can be saved from:

- the heart on a feed card,
- the hero action on the detail screen.

Both paths fetch the full detail when a summary is all the UI currently holds, because the offline cache stores the detail, not the summary.

## Reading offline

When the network fails, `RecipeDetailProvider` falls back to `StorageService.getOfflineRecipeDetail(id)`. The screen shows the cached copy with the amber `Viewing saved offline copy from your Favorites` banner. All interactive cooking features — scaling, checklists, timers, Kitchen Mode — work identically on cached data.

## Saved tab

`FavoritesScreen` lists cached summaries, newest first. It provides its own search field matching name, teaser and archive. Tapping a card opens the detail view; the always-filled heart removes it, with a SnackBar confirmation.

## Removing

Removing a favourite deletes both the id from `bakers_local_favorites` and the cached payload under `bakers_favorites_data_cache_<id>`. **Settings → Offline Storage → Clear All** does the same in bulk.

## What is not synced

Favourites are device-local. They are not pushed to Odoo, not tied to your signed-in session and not shared across devices. This is by design: no write access to the archive is assumed.
