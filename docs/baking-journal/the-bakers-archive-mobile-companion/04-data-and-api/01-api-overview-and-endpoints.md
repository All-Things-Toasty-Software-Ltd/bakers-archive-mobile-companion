---
title: "API Overview & Endpoints"
seo_title: "API Overview & Endpoints | Baking Journal"
meta_description: "Base path, versioning envelope, endpoint list and the response shapes the app expects."
slug: "the-bakers-archive-mobile-companion/data-and-api/api-overview-and-endpoints"
type: "page"
order: 1
---

# API Overview & Endpoints

## Base path

Every endpoint the app calls is under `/archive/api/v1/`. All endpoints are `auth='public'`, return JSON and need no token. The version string is also echoed in each body as `api_version`, so a future v2 can be detected without parsing URLs.

## Endpoints used

| Call | Endpoint | Notes |
| --- | --- | --- |
| `testConnection()` | `GET /archive/api/v1/archives` | Cheap probe used by the badge and Settings. |
| `fetchArchives()` | `GET /archive/api/v1/archives` | Full list; `ArchiveModel.fromJson`. |
| `fetchArchiveRecipes()` | `GET /archive/api/v1/archive/<id>?page=1&limit=30` | Returns a page of summaries. |
| `fetchRecipeDetail()` | `GET /archive/api/v1/recipe/<id>?depth=3` | Full generic serializer record. |
| Odoo probe (fallback) | `POST /web/webclient/version_info` | JSON-RPC, only used when the archive endpoint fails upstream of Odoo. |
| Odoo auth (fallback) | `POST /web/session/authenticate` | Used when the web form cannot authenticate, e.g. hidden db list. |
| Odoo session info | `POST /web/session/get_session_info` | Identity source after web-form login. |
| Odoo login | `GET/POST /web/login` | Carries `csrf_token`; session cookie flows in headers. |

## Release envelope

```json
{
  "api_version": "v1",
  "data": { ... },
  "recipes": { "page": 1, "limit": 30, "total": 12, "page_count": 1, "items": [ ... ] }
}
```

`testConnection()` treats a `200` whose body lacks `api_version` as not-Baker's-Archive and falls back to the version probe.

## Direct URLs

Convenience URLs the app constructs in `RecipeDetail.fromOdooApiResponse`:

- Image: `$server/web/image/bakers_archive.recipe/<id>/main_image`
- Web page: `$server/archive/recipe/<id>`
- Avatar: `$server/web/image/res.users/<uid>/avatar_128` and `$server/web/image/res.partner/<id>/image_128`

If the archive is mounted elsewhere on the host, only the API path needs to move; the `/web/image` path is standard Odoo.
