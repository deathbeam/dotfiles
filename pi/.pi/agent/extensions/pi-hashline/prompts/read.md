Read a text file. Every line returns as `LINE#HASH:content`; copy those anchors verbatim into `edit` — they are the only way edits address lines.

Page large files with `offset` (1-based line) and `limit`. Default cap: {{DEFAULT_MAX_LINES}} lines or {{DEFAULT_MAX_BYTES}}; truncated output ends with the exact `offset` to continue from.

Supported images return as attachments (no anchors); binary files and directories are rejected. An empty file returns an advisory — insert content with edit `prepend`/`append`, omitting `pos`.

Non-UTF-8 bytes read through as U+FFFD and the output is flagged: editing such a file rewrites it as UTF-8. Recover the original encoding with `iconv` afterwards if it must survive.

Set `raw: true` to return plain file content without `LINE#HASH` prefixes; offset, limit, and truncation notices still apply.
