---
name: flecs-remote
description: Flecs Remote API for a running Flecs app. Use when inspecting or changing live world state (entities, components, queries, stats).
---

# Flecs Remote API

A Flecs app with REST enabled serves JSON on `http://localhost:27750`. Talk to it with `curl` and `jq`. Full reference: https://www.flecs.dev/flecs/FlecsRemoteApi.html. Query language: https://www.flecs.dev/flecs/md_docs_2FlecsQueryLanguage.html.

```sh
B=localhost:27750
u() { jq -rn --arg s "$1" '$s|@uri'; }                    # URI-encode a param
curl -s "$B/world?builtin=false" | jq '.results|length'   # connection check
```

## Encoding

- Encode every `expr`, `component`, `value` and `code` param with `u`. `curl --data-urlencode` emits `+` for spaces, and Flecs reads `+` literally, so it fails on any expression with a space.
- URL paths separate with `/` (`/entity/Game/Features/CoreModule/Position`). Params separate with `.` (`component=Game.Features.CoreModule.Position`).
- Name components by full path (`Game.Features.CoreModule.Position`). Short names fail with `unresolved identifier`. Get full names from `/components`.
- Numeric ids go in paths as `%23<id>` (`/entity/%23984`). A raw `#` produces `entity '' not found`.
- The query endpoint is `/query`. `/query/` returns 404 on some versions.

```sh
curl -s "$B/query?expr=$(u 'Game.Features.CoreModule.Position, (ChildOf, $p)')&limit=10&full_paths=true"
```

## Read

Pass `limit` on every query; worlds hold thousands of entities.

| Goal | Request |
|------|---------|
| List components | `GET /components` → `jq -r '.[].name'` |
| Entity details | `GET /entity/<path>` (`?values=true&inherited=true&full_paths=true`) |
| One component value | `GET /component/<path>?component=<name>` |
| Type layout | `GET /type_info/<path>` |
| Run a query | `GET /query?expr=<expr>&limit=N&offset=N` (`&full_paths=true&entity_ids=true`) |
| Validate a query | `GET /query?expr=<expr>&try=true` |
| Query plan / profile | `&query_plan=true` / `&query_profile=true` |
| Named query | `GET /query?name=<path>` |
| All queries/systems | `GET /queries` |
| Tables | `GET /tables` |
| World stats | `GET /stats/world?period=1s` (`1m`, `1h`, `1d`, `1w`; needs Stats module) |
| System timings | `GET /stats/pipeline?period=1s` |

Values appear only for types with reflection data. Unreflected components (common in Flecs.NET apps) show `null` or `0`, and `/type_info` returns `0`.

## Write (confirm with the user first)

These change the live app.

| Goal | Request |
|------|---------|
| Create entity | `PUT /entity/<path>` |
| Delete entity | `DELETE /entity/<path>` |
| Add/set component | `PUT /component/<path>?component=<name>&value=<value>` |
| Remove component | `DELETE /component/<path>?component=<name>` |
| Enable/disable | `PUT /toggle/<path>?enable=false[&component=<name>]` |
| Run/update script | `PUT /script/<path>?code=<code>[&try=true]` |
| Action | `PUT /action/shrink_memory` |

Values use Flecs script syntax: `{x: 10, y: 20}`.
