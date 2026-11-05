---
title: "Kitchen Mode"
seo_title: "Kitchen Mode | Baking Journal"
meta_description: "The distraction-free, large-typography step-by-step mode with a per-step timer."
slug: "the-bakers-archive-mobile-companion/features/kitchen-mode"
type: "page"
order: 4
---

# Kitchen Mode

Kitchen Mode is the app's smallest screen and its most specialised: one step at a time, readable across the room, usable with doughy hands.

## Entering

From `RecipeDetailScreen`, the **Kitchen Mode** button in the instructions header pushes the screen. It always uses the full instruction list of the currently open recipe; scaling and checklist state are not shown here.

## What you see

- Recipe name in the app bar with a single `X` to exit.
- A thin progress bar.
- `Step N of M` and the step's category name as an amber pill.
- The step text in a large display-serif style.
- A timer when the step has a duration.
- Two or three fixed bottom buttons depending on position: **Previous**, **Next Step** / **Finish Bake**.

## Behaviour

- Previous is disabled on step 1; Next becomes **Finish Bake** on the last step and returns to the detail screen.
- Tapping the pause/play icon starts or pauses that step's countdown; tapping reset restores the full duration.
- Leaving the screen cancels any running ticker.

## Design intent

Kitchen Mode deliberately avoids navigation menus, search and tangent screens. It assumes you already scrolled and made the mess. Keep it simple: one step, one timer, two buttons.

## Accessibility

The step text uses `displayLarge`-class sizing, the timer is a labelled control, and the buttons are at least 18dp of vertical padding so they can be hit with wet fingers.
