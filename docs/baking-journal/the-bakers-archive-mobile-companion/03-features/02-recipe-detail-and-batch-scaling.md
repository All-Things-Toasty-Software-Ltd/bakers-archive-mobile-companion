---
title: "Recipe Detail & Batch Scaling"
seo_title: "Recipe Detail & Batch Scaling | Baking Journal"
meta_description: "The full recipe screen: hero image, attribution, quick stats, batch multipliers, baker's math and checklists."
slug: "the-bakers-archive-mobile-companion/features/recipe-detail-and-batch-scaling"
type: "page"
order: 2
---

# Recipe Detail & Batch Scaling

`RecipeDetailScreen` is the most dense screen in the app. It reads `/archive/api/v1/recipe/<id>?depth=3` through `RecipeDetailProvider`.

## Hero and attribution

A `SliverAppBar` expands to 280px with the cover image. The overlay carries the back button, favourite and share actions, plus the archive chip when known. Below the hero:

- recipe title and italic subtitle,
- a fact row: avatar, author/original author, source link text and country chip when present,
- quick stats: ingredient count, step count, view count,
- offline-fallback banner when applicable.

## Batch scaling

Multipliers are fixed: `0.5×, 1×, 1.5×, 2×, 3×`. Selecting one stores the choice in `RecipeDetailProvider` so `IngredientTile` re-renders quantities immediately. Quantities are trimmed of trailing `.0` and keep a single decimal where needed.

`BakersMath.extractPercentage()` reads percentages such as `"80% in Baker's math."` from the notes column and shows the whole-number pill on the right of each ingredient.

## Checklists

Ingredient rows and instruction steps are individually tickable for mise en place. `Reset Checks` clears both sets. Completed steps are struck through and, when done, show a green check instead of the step number.

## Method grouping

Instructions are grouped by the `category_id` relation (e.g. “Mix the dough”, “Shape and bake”). Each heading uses the relation's `display_name`, trailing-colon strips included. Within each group, steps are sorted by `sequence`.

## Timers

A step with a non-zero `time` (minutes) exposes a circular-ish timer pill. Tapping it promotes the step into the shared `RecipeDetailProvider` countdown: start, pause/resume and reset.

## Sharing

The share button emits the title, teaser and `$server/archive/recipe/<id>` so a recipient can open the canonical page in any browser.
