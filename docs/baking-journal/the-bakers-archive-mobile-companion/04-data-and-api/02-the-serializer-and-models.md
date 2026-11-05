---
title: "The Serializer & Models"
seo_title: "The Serializer & Models | Baking Journal"
meta_description: "How the generic serializer output is mapped into Dart models, including Odoo field tricks."
slug: "the-bakers-archive-mobile-companion/data-and-api/the-serializer-and-models"
type: "page"
order: 2
---

# The Serializer & Models

The app does not assume a fixed “Recipe” shape. Baker's Archive emits a generic record:

```json
{
  "id": 42,
  "model": "bakers_archive.recipe",
  "display_name": "Everyday Sourdough",
  "fields": [ { "name": "teaser", "value": "…" } ]
}
```

## Top-level models

`RecipeDetail.fromOdooApiResponse(root)` reads `root['data']` (or root, if flat) and loops over `fields`, switching on the lower-cased field name:

- Scalars: `name`, `subtitle`, `teaser`, `description`, `notes`, `visits`, `published_date`.
- Relations: `archive_id`, `author_id`, `original_author_id`, `source_id`, `license`, `country_id`.
- Lines: `ingredient_ids`, `instruction_ids`, `tag_ids`.

`IngredientModel.fromFieldMap()` and `InstructionModel.fromFieldMap()` accept either the serializer's nested field list or a partially flat object, so cached favourites and future payloads both parse.

## Odoo quirks handled

- Empty `Char` arrives as `false`, not `""` — the subtitle/teaser mappings ignore non-string values.
- HTML arrives with real markup; the detail model passes `description` and `notes` through a small HTML stripper (`<br>`/`<p>` to newlines, tags removed, common entities decoded).
- `category_name` is trimmed of a trailing colon (`"Mix the dough:"` → `"Mix the dough"`).
- Percentages live in the notes column; `BakersMath.extractPercentage` pulls e.g. `80%` out for badge display.
- Instructions are always output sorted by `sequence`.

## Favourite round-trip

`RecipeDetail.toJson()`/`fromJson()` mirror the cached network copy exactly, including image URLs and the `rawJson` envelope, so offline reopening is indistinguishable from the cached response.

## Extending

To surface a new field, add its `case` to `RecipeDetail.fromOdooApiResponse`, expose it on the class and teach the affected widget to render it. Do **not** fork the serializer in the companion — new Odoo fields should flow as ordinary `{name, value}` entries.
