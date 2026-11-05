---
title: "Explore & Search"
seo_title: "Explore & Search | Baking Journal"
meta_description: "Archive chips, the All Archives feed, search, card layout and empty/error states."
slug: "the-bakers-archive-mobile-companion/features/explore-and-search"
type: "page"
order: 1
---

# Explore & Search

The Explore tab is the app's front door. It combines archive selection, lightweight search and the recipe card grid.

## Archive chips

- `All Archives` (default) is the merged view.
- One chip per archive, generated from `/archive/api/v1/archives`.
- Selecting a chip reloads the recipe page for that archive only.

When no archive is selected, `ArchiveProvider` requests each archive's recipe page and merges them, dropping duplicates by recipe id, so a recipe that appears in two indexes still appears once.

## Search

Tap the magnifier to reveal the search field. Search is local, instant and case-insensitive; it matches:

- recipe name,
- teaser,
- archive name.

The query is not persisted — leaving and returning resets it.

## Cards

Each card shows:

- 16:9 cover image (or a bread-slice placeholder),
- archive badge on the image,
- filled/outline heart matching local favourite state,
- title and teaser,
- published date (if present) and `View Recipe`.

Tapping the heart fetches the full recipe and toggles the favourite. If that fetch fails (often because you are offline), the heart does not flip rather than silently doing nothing.

## Layout rules

- Width `< 600px` — single-column `ListView`.
- Width `≥ 600px` — two-column grid with `0.85` aspect ratio.
- Pull-to-refresh re-fetches the selected archive scope.

## States

| State | Trigger | UI |
| --- | --- | --- |
| Loading | Initial load with no cached rows | Full-view bread loader. |
| Error with empty feed | API error and zero recipes | Cloud-off icon, message, retry button. |
| Empty | Successful response, no matches | Bread icon with a hint to change the archive or query. |
| Content | At least one match | Cards as above. |
