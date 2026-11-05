---
title: "Error Handling"
seo_title: "Error Handling | Baking Journal"
meta_description: "Provider error strings, timeouts, loading/empty/error states and the offline rescue path."
slug: "the-bakers-archive-mobile-companion/data-and-api/error-handling"
type: "page"
order: 3
---

# Error Handling

The UI never surfaces exceptions directly. Each provider converts failures into a nullable message and a friendly empty state.

## Feed states

| Signal | Meaning | UI |
| --- | --- | --- |
| `isLoading && list empty` | First request pending | Full-screen loader |
| `errorMessage != null && list empty` | Request failed with no cached data | Cloud-off + retry |
| `filteredRecipes.isEmpty` | Success but no rows/matches | Empty illustration |
| otherwise | Data available | Cards |

## Detail states

`RecipeDetailProvider.loadRecipe()` walks three outcomes:

1. **Success** — recipe is set, offline flag false.
2. **Failure + cache hit** — cached recipe is used, offline flag true, no error banner if a teaser is available, amber banner shown otherwise.
3. **Failure + no cache** — `errorMessage` set and a centred retry screen.

Favourite toggle fetch failures are silent to `FavoritesProvider`; the heart simply does not toggle.

## Authentication errors

Both authentication paths return an `AuthResult`. Raw exceptions are trimmed of the `Exception:` prefix. Wrong credentials and unknown database produce the same final message: `"Invalid credentials or unable to authenticate with Odoo server."`

## Timeouts and transient failures

The app does not auto-retry. Retries are explicit (pull-to-refresh, `Try again`). This keeps mobile behaviour predictable on metered networks and prevents the connection badge from lying during intermittent coverage.

## Logging

There is no remote logging. Errors exist only as UI state. If you need more, run `flutter run --verbose` or reproduce against a local Odoo with the Flutter DevTools logger.
