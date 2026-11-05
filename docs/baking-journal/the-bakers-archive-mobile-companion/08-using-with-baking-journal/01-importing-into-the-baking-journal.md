---
title: "Importing Into The Baking Journal"
seo_title: "Importing Into The Baking Journal | Baking Journal"
meta_description: "A repeatable workflow for turning this Markdown tree into project, category and page records."
slug: "the-bakers-archive-mobile-companion/using-with-baking-journal/importing-into-the-baking-journal"
type: "page"
order: 1
---

# Importing Into The Baking Journal

These pages are authored to be turned into `baking_journal.project`, `baking_journal.category` and `baking_journal.page` records without editorial rewrites.

## Mapping

| Markdown | Baking Journal record |
| --- | --- |
| `00-project-index.md` | Project homepage (`/journal/the-bakers-archive-mobile-companion`). |
| `<n>-<category>/00-category-index.md` | Category landing page. |
| `<n>-<category>/<n>-<page>.md` | Single page in that category. |
| `order:` | `sequence`. |
| `slug:` | `website_slug` (or `ir.http._slug()` on write). |
| `meta_description` | `summary`. |
| `seo_title` | `website_meta_title`. |
| Body | `content` as HTML built with the Page Builder. |

The Markdown keeps a stable `NN-category/NN-page` ordering so imports remain deterministic even if incremental re-runs are applied.

## Suggested import order

1. Create the project record with `name`, `subtitle`, `summary`, `icon: fa-mobile` (or a bread-themed icon class), `repository_url` and `sequence`.
2. Create each category from its `00-category-index.md`.
3. Create each page in category/file order.
4. Re-read the generated tree and spot-check: project → categories → pages.
5. Publish the project, categories and pages.

## HTML body guidance

The Page Builder treats `content` as HTML. Markdown headings/paragraphs/tables/images are all acceptable; for tables prefer ordinary `<table>` blocks because the builder may strip raw pipes. Keep code fences inside `<pre><code>` only when they will not be modified inline by an editor afterwards.

## Drift control

Keep `slug:` stable. Changing one breaks internal links between pages and the sidebar ordering. When a page needs a rename, update the file on disk, update `slug:` and re-import only that record.

## Publishing checklist

- Project published.
- Each category published.
- Each page published (check `website_published`).
- The `/journal/the-bakers-archive-mobile-companion` URL loads and the sidebar lists every category.
- Previous/next links traverse the order you imported.
