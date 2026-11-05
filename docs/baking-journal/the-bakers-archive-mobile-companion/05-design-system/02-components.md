---
title: "Components"
seo_title: "Components | Baking Journal"
meta_description: "BreadLoader, RecipeCard, ArchiveChipList, IngredientTile, StepTimerWidget and ServerStatusBadge."
slug: "the-bakers-archive-mobile-companion/design-system/components"
type: "page"
order: 2
---

# Components

## BreadLoader

Pulsing bread-slice disc used while archives, recipes and settings probes are in flight. Accepts `size` and `message`.

## RecipeCard

The unit of the Explore and Saved feeds. Maintains:

- 16:9 image slot with rounded clipping,
- scrimless badge row: archive left, favourite right,
- title (max 2 lines), teaser (max 2 lines), date row,
- footer row with `View Recipe` affordance.

Toggle semantics: the parent owns the tap and favourite callbacks; the card itself is `StatelessWidget`.

## ArchiveChipList

Horizontal `ChoiceChip` row. The leading "All Archives" chip is `selectedArchive == null`; selected chips render with a white check.

## IngredientTile

The workhorse of the recipe detail screen: numeric quantity pill, name, notes, baker percentage tag and a circular checkbox. Strike-through and dimming indicate checked state.

## StepTimerWidget

Small inline countdown (`mm:ss`) with pause/resume and reset. States:

- Running — gold outline/fill;
- Paused — same visual, pause icon flips to play;
- Complete (`00:00`) — green `Done!` with check icon.

## ServerStatusBadge

Top-right pill in the Explore app bar. See **Application Shell & Navigation** for the mapping.

## Composing

These widgets are deliberately presentation-only. Provider reads happen above the widget, not inside it, to keep future previews and pure widget tests straightforward.
