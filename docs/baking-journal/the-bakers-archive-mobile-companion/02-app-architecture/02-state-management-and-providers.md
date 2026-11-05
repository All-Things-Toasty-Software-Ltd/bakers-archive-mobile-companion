---
title: "State Management & Providers"
seo_title: "State Management & Providers | Baking Journal"
meta_description: "The Provider setup: Auth, Archive, RecipeDetail, Favorites and Theme providers."
slug: "the-bakers-archive-mobile-companion/app-architecture/state-management-and-providers"
type: "page"
order: 2
---

# State Management & Providers

The app uses `package:provider` with `ChangeNotifier`s. Each provider owns one slice of UI state and talks to a service; widgets `watch` only what they rebuild on.

## AuthProvider

Owns the selected server URL, the database override, the connection probe result and the signed-in `OdooUser`.

- Constructor probes the default/current server immediately.
- `setServerUrl()` normalises the URL, persists it and re-tests before returning success so the UI can distinguish a changed-but-unreachable host.
- `signIn()` retries via the web-form flow and, if the host hides its database list, falls back to JSON-RPC once the database is known or probed.
- `signOut()` only clears the local session; it does not attempt server-side session destruction.

## ArchiveProvider

Owns the archive list, the selected archive (or `null` = All), the recipe summaries and the live search query.

- `loadArchives()` fetches `/archive/api/v1/archives`; on success it also refreshes recipes for the current selection.
- With no archive selected it walks every archive, de-duplicates by recipe id and merges summaries.
- `filteredRecipes` performs the case-insensitive name/teaser/archive match used by the Explore feed.

## RecipeDetailProvider

Owns the currently open recipe plus the interactive cook-state that should not be shared across screens:

- batch multiplier, ingredient checked ids, completed step ids;
- by-step countdown timer (`startStepTimer`, `pauseResumeTimer`, `resetTimer`);
- `loadRecipe()` falls back to the offline cached copy when the network call throws and a locally stored detail exists.

## FavoritesProvider

Owns the set of local favourite ids and the cached summaries. It wraps `StorageService` and re-notifies on toggles.

## ThemeProvider

Maps persisted strings (`warm_crust`, `dark_toast`, `system`) to Flutter's `ThemeMode`. It reads the persisted value on construction so a cold start does not flash the wrong theme.
