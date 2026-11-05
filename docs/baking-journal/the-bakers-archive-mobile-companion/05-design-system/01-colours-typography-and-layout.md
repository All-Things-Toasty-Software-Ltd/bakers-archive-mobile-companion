---
title: "Colours, Typography & Layout"
seo_title: "Colours, Typography & Layout | Baking Journal"
meta_description: "The two palettes, Inter/Playfair pairing, radius rules and spacing."
slug: "the-bakers-archive-mobile-companion/design-system/colours-typography-and-layout"
type: "page"
order: 1
---

# Colours, Typography & Layout

## Palette

All raw colours live in `lib/core/theme/bread_colors.dart`.

### Crust / amber accents

| Token | Hex | Role |
| --- | --- | --- |
| `crustGold` | `#D97706` | Primary light accent, chips |
| `crustGoldDark` | `#B45309` | Light-mode primary, icons, invoked buttons |
| `crustDeep` | `#78350F` | Dark text on gold / progress tints |
| `butterYellow` | `#FBBF24` | Dark-mode highlights |

### Surfaces

`crumbWhite`, `crumbCream`, `crumbWarmGrey`, `crumbBorder` for light; `ovenBlack`, `ovenCharcoal`, `toastSurface`, `toastBorder` for dark. Error is `ovenRed`; success is `yeastGreen`.

## Typography

- **Inter** — all body/label/caption text.
- **Playfair Display** — `displayLarge`, `displayMedium`, `titleLarge` and the app-bar title.
- Tracking: display sizes use `letterSpacing: -0.2`; section headers use `+0.8`.

## Radius and elevation

- Cards: `16px` (modern recipe cards use `18px`), no shadow — a 1px outline in `outline`.
- Inputs: `14px`, filled `crumbWarmGrey`/`toastSurface`.
- Buttons: `12px` radius, zero elevation.
- Chips: pill radius, `0.8` border.
- Dialogs/snackbars keep Material defaults.

## Spacing

Screen edge insets are `16px`; section gaps use multiples of 8 (`8`, `12`, `14`, `16`, `24`, `32`). Major surfaces use zero `margin` on `CardTheme` so the caller controls vertical rhythm.

## Theming choice

Use tokens, not hex. `BreadTheme._buildTheme()` derives the two `ColorScheme`s from the tokens, and both `lightTheme` and `darkTheme` are produced from the same function, so a palette change does not strand one mode behind the other.
