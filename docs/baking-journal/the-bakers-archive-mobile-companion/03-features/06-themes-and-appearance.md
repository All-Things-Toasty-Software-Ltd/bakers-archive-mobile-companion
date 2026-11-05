---
title: "Themes & Appearance"
seo_title: "Themes & Appearance | Baking Journal"
meta_description: "Warm Crust, Dark Toast and system-synced appearance, plus the tokens behind them."
slug: "the-bakers-archive-mobile-companion/features/themes-and-appearance"
type: "page"
order: 6
---

# Themes & Appearance

The app ships two hand-tuned palettes and honours the OS setting.

| Setting | Result |
| --- | --- |
| `warm_crust` | Artisan light: crumb cream surfaces, toasted-amber accents. |
| `dark_toast` | Oven dark: charcoal surfaces, roasted-honey accents. |
| `system` | Follows the operating system brightness. |

## Token source

- `BreadColors` — raw hex tokens for crust, crumb, toast, text and accents (`crustGold`, `crumbWhite`, `ovenBlack`, `textLightPrimary`, …).
- `BreadTheme` — assembles a full Material 3 `ThemeData` per brightness, including `ColorScheme`, `textTheme`, input/card/button/chip themes and the Playfair Display vs Inter split.

## Usage notes

- Body text stays Inter for readability; large titles and the app bar use Playfair Display.
- Buttons use 12px corners, cards 16px, inputs 14px.
- Chips retain `selectedColor = crustGoldDark` for archive selection.
- The app bar has no elevation and transparent surface tint; the content itself separates sections.

## Changing it at runtime

Settings radio controls call `ThemeProvider.setMode(mode)`. The provider persists the value and flips `MaterialApp.themeMode`, so no restart is required.

## If you extend the palette

Work from tokens rather than raw colours. Both themes are rebuilt from the same `_buildTheme()` so a colour change in `BreadColors` propagates consistently. Do not introduce a third `Brightness` branch without also updating `BreadTheme` — the fed-back Material theme assumes exactly two.
