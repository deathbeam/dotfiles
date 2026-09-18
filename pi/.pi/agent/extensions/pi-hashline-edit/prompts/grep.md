Search files using ripgrep. Every matched line returns as `LINE#HASH:content` — copy those anchors verbatim into `edit` without a prior `read`.

The `pattern` is a regular expression unless `literal: true`. Results respect `.gitignore` by default (ripgrep's default). Use `path` to scope to a file or directory; use `glob` to filter by filename pattern (e.g. `"**/*.ts"`).

Set `context` (0–5) to include surrounding lines around each match. Set `limit` to cap matched lines (default 50, max 200).

When results are too broad, narrow in this order: read the match count first, then scope with `path`/`glob`, then tighten `pattern`, and only add `context` once the set is small.
