---
title: "Application Shell & Navigation"
seo_title: "Application Shell & Navigation | Baking Journal"
meta_description: "How main.dart, the bottom navigation bar and IndexedStack structure the app."
slug: "the-bakers-archive-mobile-companion/app-architecture/application-shell-and-navigation"
type: "page"
order: 1
---

# Application Shell & Navigation

## Entry point

`lib/main.dart` is deliberately small. It initialises bindings, creates `StorageService` from `shared_preferences`, then wraps the app in a `MultiProvider`:

```dart
MultiProvider(
  providers: [
    Provider<StorageService>.value(value: storageService),
    ChangeNotifierProvider<ThemeProvider>(...),
    ChangeNotifierProvider<AuthProvider>(...),
    ChangeNotifierProvider<ArchiveProvider>(...),
    ChangeNotifierProvider<RecipeDetailProvider>(...),
    ChangeNotifierProvider<FavoritesProvider>(...),
  ],
  child: const BakersArchiveApp(),
)
```

`BakersArchiveApp` applies `BreadTheme.lightTheme` / `BreadTheme.darkTheme`, watches `ThemeProvider` for the chosen mode, and sets `HomeScreen` as the home.

## Bottom navigation

`HomeScreen` owns an `IndexedStack` with three tabs:

| Index | Tab | Screen |
| --- | --- | --- |
| 0 | Explore | `HomeScreen._buildExploreTab` |
| 1 | Saved | `FavoritesScreen` |
| 2 | Settings | `SettingsScreen` |

Using `IndexedStack` keeps tab state alive while switching — scroll position and the search query survive a round-trip to Settings.

## Top bar

The Explore tab shows a brand row (bread icon + title) and a `ServerStatusBadge`. The badge reports:

- `Connecting…` while a probe is in flight,
- the host name in green when the archive API answers,
- `Odoo Connected` in amber when only base Odoo responds,
- `Offline` in red otherwise.

It is tappable and jumps to the Settings tab.

## Recipe routes

Recipe reading is a normal `Navigator` push to `RecipeDetailScreen`. Kitchen Mode pushes on top of that. There is no global router package — the app is small enough that a `Route` stack remains easier to audit.

## Responsive behaviour

The feed switches at `600px`: single column list on handsets, two-column grid on tablets and desktop/web widths.
