# PoE leveling overlay scripts

Requires `quickshell` (with `qs`), `python3` (stdlib only) and a Path of Exile 1
`Client.txt`.

## import_exile_data.sh

Copies areas, guide, hint images and inline icons from an Exile-UI checkout into
`../data`. Replaces `data/hints` and `data/icons` completely, so removed files do
not linger.

```bash
./scripts/import_exile_data.sh [path-to-Exile-UI]   # default: ~/git/Exile-UI
```

## toggle.sh

Hides or shows the panel. Starts `quickshell -c poe-leveling` when it is not running.

```bash
./scripts/toggle.sh
```

## test_overlay.sh

Runs the shell against a fake log (`/tmp/poe_test_client.txt`) and appends zone
changes. Set `POE_LOG_PATH` to use another path.

```bash
./scripts/test_overlay.sh
```

## Tests

```bash
python3 -m unittest discover -s scripts -v
```

## Keybinds

| Key | Action |
| --- | --- |
| `SUPER + z` | toggle the panel (starts the shell if needed) |
| `SUPER + Right` | next guide page |
| `SUPER + Left` | previous guide page |
| `SUPER + SHIFT + z` | show/hide hint images |
| `SUPER + SHIFT + Left` | reset progress and timer |

They call `qs ipc -c poe-leveling call leveling <next|prev|reset|toggle|hints>`.

## Configuration

Edit `../Config.qml`: `anchor`, `margin`, `screenName`, `width`, `fontSize`,
`opacity`, `leagueStart`, `bandit`, `characterName`, `logPath`. `POE_LOG_PATH`
overrides the log path. Progress is stored in
`${XDG_STATE_HOME:-~/.local/state}/poe-leveling/state.json`.
