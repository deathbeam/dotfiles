#!/usr/bin/env python3
"""Path of Exile 1 leveling tracker.

Follows the Exile-UI leveling guide from the game's Client.txt and prints one
JSON state object per line on stdout. Commands arrive on stdin, one per line:
next, prev, reset.
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import select
import sys
import time
from pathlib import Path

ICON_SIZE = 16  # px, inline icon size

COLOR = {
    "text": "#EEE8D5",
    "dim": "#93A1A1",
    "area": "#FEC076",
    "quest": "#FFDB1F",
    "item": "#9CD64B",
    "boss": "#FF8111",
    "alt": "#CC99FF",
    "hint": "#66D9EF",
    "lab": "#569777",
}
COLOR_NAMES = {
    "red": "#E06C75",
    "lime": "#9CD64B",
    "aqua": "#66D9EF",
    "white": "#EEE8D5",
    "fuchsia": "#CC99FF",
}
XP_COLOR = {"lime": COLOR["item"], "yellow": "#E5C07B", "orange": COLOR["boss"], "red": "#E06C75"}

AREA_RE = re.compile(r'Generating level (\d+) area "([^"]+)"')
LEVEL_RE = re.compile(r":\s*([^:()]+?) \(([^)]+)\) is now level (\d+)")
COLOR_TAG_RE = re.compile(r"\(color:([0-9a-zA-Z]+)\)")
IMG_TAG_RE = re.compile(r"\(img:([^)]*)\)")
HEX_COLOR_RE = re.compile(r'color="(#[0-9A-Fa-f]{6})"')
AREAID_RE = re.compile(r"areaid([A-Za-z0-9_]+)")

DEFAULT_LOG = "~/.local/share/Steam/steamapps/common/Path of Exile/logs/LatestClient.txt"


# --------------------------------------------------------------------------- data


def load_areas(path: Path) -> dict[str, dict]:
    """area id -> {name, act, recipe}."""
    areas = {}
    for act_number, act in enumerate(json.loads(Path(path).read_text()), start=1):
        for entry in act:
            areas[entry["id"]] = {
                "name": entry.get("name") or entry.get("map_name") or entry["id"],
                "act": act_number,
                "recipe": entry.get("crafting_recipe", ""),
            }
    return areas


def load_pages(path: Path) -> list[dict]:
    """Flatten the per-act guide into one ordered list of pages."""
    pages = []
    for act in json.loads(Path(path).read_text()):
        for page in act:
            pages.append(page if isinstance(page, dict) else {"lines": page, "condition": None})
    return pages


def load_hints(directory: Path) -> dict[str, str]:
    """hint phrase as written in the guide -> file:// URL."""
    hints = {}
    for path in sorted(Path(directory).glob("*")):
        if path.suffix.lower() in (".jpg", ".jpeg", ".png"):
            hints[path.stem.replace("_", " ").lower()] = path.resolve().as_uri()
    return hints


# --------------------------------------------------------------------- conditions


def page_matches(page: dict, league_start: bool, bandit: str) -> bool:
    condition = page.get("condition")
    if not condition:
        return True
    kind, value = condition
    if kind == "league-start":
        return (value == "yes") == league_start
    if kind == "bandit":
        return bandit in (value if isinstance(value, list) else [value])
    return True


def visible_lines(page: dict, league_start: bool) -> list[str]:
    """Drop steps tagged for the other run type, plus optional steps."""
    lines, skip = [], False
    for line in page["lines"]:
        if "(hint)_" not in line:  # hint sub-lines inherit their parent's tag
            skip = "optional:" in line or ("twinkrun:" if league_start else "leaguestart:") in line
        if not skip:
            lines.append(line)
    return lines


def page_areas(page: dict, league_start: bool) -> list[str]:
    """Area ids this page sends you to; hint sub-lines are not destinations."""
    return [
        area_id
        for line in visible_lines(page, league_start)
        if "(hint)_" not in line
        for area_id in AREAID_RE.findall(line)
    ]


# ------------------------------------------------------------------------- markup


def dim(hex_color: str) -> str:
    """Blend a colour towards the panel background (for hint sub-lines)."""
    r, g, b = (int(hex_color[i : i + 2], 16) for i in (1, 3, 5))
    return "#%02X%02X%02X" % tuple(round(c * 0.62) for c in (r, g, b))


def _font(color: str, text: str) -> str:
    return f'<font color="{color}">{text}</font>'


class Renderer:
    """Turns one Exile-UI guide line into Qt rich text."""

    def __init__(self, areas: dict[str, dict], hints: dict[str, str], icon_dir: Path):
        self.areas = areas
        self.hints = hints
        self.icon_dir = Path(icon_dir)
        self._icons: dict[str, str] = {}

    def icon(self, name: str) -> str:
        if name not in self._icons:
            path = self.icon_dir / f"{name}.png"
            self._icons[name] = path.resolve().as_uri() if path.exists() else ""
        return self._icons[name]

    def hints_in(self, line: str) -> list[str]:
        text = line.lower()
        return [url for phrase, url in self.hints.items() if phrase in text]

    def render(self, line: str, current_act: int) -> tuple[str, bool]:
        """Return (html, is_hint_subline)."""
        hint = "(hint)_" in line
        text = line.split(" ;", 1)[0].split("|| lilly:", 1)[0]
        text = text.replace("(hint)__", "").replace("(hint)_", "")
        text = re.sub(r"(optional|leaguestart|twinkrun):", "", text)
        # keep multi-word hint phrases in one token so they colour as a unit
        for phrase in sorted(self.hints, key=len, reverse=True):
            if phrase in text.lower():
                text = re.sub(re.escape(phrase), phrase.replace(" ", "_"), text, flags=re.IGNORECASE)

        parts: list[str] = []
        kill = False
        previous_icon = ""
        for token in text.split():
            icon_before, previous_icon = previous_icon, ""
            if token in ("||", "|"):
                parts.append(_font(COLOR["dim"], "or"))
                continue
            token = token.replace("&&", "&")
            explicit = ""
            match = COLOR_TAG_RE.match(token)
            if match:
                value = match.group(1).lower()
                explicit = COLOR_NAMES.get(value, f"#{value}" if len(value) == 6 else "")
                token = token[match.end() :]
            if not token:
                continue
            if token.startswith("(img:"):
                name = IMG_TAG_RE.match(token).group(1).replace(" ", "_")
                url = self.icon(name)
                parts.append(
                    f'<img src="{url}" width="{ICON_SIZE}" height="{ICON_SIZE}">'
                    if url
                    else _font(COLOR["dim"], f"[{html.escape(name, quote=False)}]")
                )
                previous_icon = name
                continue
            if token.startswith("(quest:"):
                parts.append(_font(COLOR["item"], html.escape(token[7 : token.find(")")].replace("_", " "), quote=False)))
                continue
            if token.startswith("(lvl:"):
                parts.append(_font(COLOR["dim"], html.escape(token.replace("(lvl:", "("), quote=False)))
                continue
            if token.startswith("areaid"):
                area_id = AREAID_RE.match(token).group(1)
                area = self.areas.get(area_id)
                if area:
                    label = area["name"] if area["act"] == current_act else f"Act {area['act']} | {area['name']}"
                    parts.append(_font(COLOR["area"], html.escape(label, quote=False)))
                else:
                    parts.append(_font(COLOR["dim"], html.escape(area_id, quote=False)))
                continue
            if "<" in token and ">" in token:
                label = token.strip("<>").replace("_", " ").rstrip("0123456789")
                parts.append(_font(COLOR["quest"], html.escape(label, quote=False)))
                continue

            word = token.replace("_", " ")
            if word.lower() in self.hints:
                color = COLOR["hint"]
                word = word.rstrip("0123456789")
            elif icon_before in ("arena", "in-out2"):
                color = COLOR["alt"]
            elif kill and word not in ("everything", "it"):
                color = COLOR["boss"]
            elif word.startswith("arena:"):
                color = COLOR["boss"]
            elif "trial" in word or "lab" in word:
                color = COLOR["lab"]
            else:
                color = COLOR["text"]
            parts.append(_font(explicit or color, html.escape(word, quote=False)))
            kill = word == "kill"

        markup = " ".join(parts).replace(" ,", ",").replace(" .", ".")
        if hint:
            markup = HEX_COLOR_RE.sub(lambda m: f'color="{dim(m.group(1))}"', markup)
        return markup, hint


# ----------------------------------------------------------------------------- xp


def xp_info(char_level: int, area_level: int, zone_id: str) -> tuple[str, str]:
    """PoE1 experience penalty (Exile-UI Leveltracker_Experience)."""
    if not char_level or not area_level:
        return "", ""
    safe_zone = "hideout" in zone_id or zone_id.endswith("_town")
    level = char_level
    effective = level if safe_zone else float(area_level)
    if not safe_zone and effective > 70:
        effective = -0.03 * effective**2 + 5.17 * effective - 144.9

    safe = 3 + level // 16
    difference = abs(level - effective)
    safezone_diff = 0 if difference <= safe else effective - (level + safe * (1 if effective > level else -1))
    penalty = max(difference - safe, 0) ** 2.5
    multiplier = ((level + 5) / (level + 5 + penalty)) ** 1.5
    if level > 94:
        table = {95: 1.069518717, 96: 1.129943503, 97: 1.2300123, 98: 1.393728223, 99: 1.666666667}
        multiplier *= (1 / (1 + 0.1 * (level - 94))) / table.get(level, 1.0)
    multiplier = max(multiplier, 0.01)

    if safe_zone:
        return "100%", XP_COLOR["lime"]
    text = f"{round(multiplier * 100)}%" + (f" ({safezone_diff:+.0f})" if safezone_diff else "")
    if round(multiplier * 100) >= 100:
        return text, XP_COLOR["lime"]

    level_diff = level - area_level
    gap = 3 + level // 16 - abs(level_diff)
    if level_diff > 0:
        key = "orange" if level_diff == 1 else "red"
    elif gap > 0:
        key = "lime"
    elif gap == 0:
        key = "yellow"
    elif gap == -1:
        key = "orange"
    else:
        key = "red"
    return text, XP_COLOR[key]


def format_seconds(seconds: float) -> str:
    hours, rest = divmod(int(seconds), 3600)
    minutes, secs = divmod(rest, 60)
    return f"{hours}:{minutes:02d}:{secs:02d}" if hours else f"{minutes}:{secs:02d}"


# -------------------------------------------------------------------------- state


class Tracker:
    """Guide progress, character level and run timer."""

    def __init__(self, areas, pages, renderer, state_path: Path, league_start: bool, bandit: str):
        self.areas = areas
        self.pages = pages
        self.renderer = renderer
        self.state_path = Path(state_path)
        self.league_start = league_start
        self.bandit = bandit
        self.page = 0
        self.char_level = 0
        self.zone_id = ""
        self.area_level = 0
        self.timer = {"total": 0.0, "act": 0.0, "act_number": 1, "last": time.time()}
        self.load_state()

    # -- persistence

    def load_state(self):
        try:
            saved = json.loads(self.state_path.read_text())
        except (OSError, ValueError):
            return
        self.page = min(max(int(saved.get("page", 0)), 0), len(self.pages) - 1)
        self.char_level = int(saved.get("char_level", 0))
        for key in ("total", "act", "act_number"):
            if key in saved.get("timer", {}):
                self.timer[key] = saved["timer"][key]
        if not self.page_ok(self.page):  # saved page filtered out by the current conditions
            self.page = next((i for i in range(self.page + 1, len(self.pages)) if self.page_ok(i)), self.page)

    def save_state(self):
        try:
            self.state_path.parent.mkdir(parents=True, exist_ok=True)
            self.state_path.write_text(
                json.dumps(
                    {
                        "page": self.page,
                        "char_level": self.char_level,
                        "timer": {k: self.timer[k] for k in ("total", "act", "act_number")},
                    }
                )
            )
        except OSError as error:
            print(f"cannot save state: {error}", file=sys.stderr)

    # -- progress

    @property
    def act(self) -> int:
        return self.areas.get(self.zone_id, {}).get("act", 0)

    def page_ok(self, index: int) -> bool:
        return 0 <= index < len(self.pages) and page_matches(self.pages[index], self.league_start, self.bandit)

    def step(self, direction: int) -> bool:
        """Move to the next page whose condition holds; False at the ends."""
        index = self.page
        while True:
            index += direction
            if not 0 <= index < len(self.pages):
                return False
            if self.page_ok(index):
                break
        self.page = index
        self.save_state()
        return True

    def reset(self):
        self.page = 0
        self.timer.update({"total": 0.0, "act": 0.0, "act_number": max(self.act, 1), "last": time.time()})
        self.save_state()

    def enter_area(self, zone_id: str, area_level: int, advance: bool = True):
        self.zone_id, self.area_level = zone_id, area_level
        if self.act > self.timer["act_number"]:  # entered a later act: bank the act timer
            self.timer["total"] += self.timer["act"]
            self.timer["act"] = 0.0
            self.timer["act_number"] = self.act
        if advance and zone_id in page_areas(self.pages[self.page], self.league_start):
            self.step(1)

    def set_level(self, level: int):
        self.char_level = level

    def tick(self):
        now = time.time()
        elapsed = now - self.timer["last"]
        self.timer["last"] = now
        if "hideout" not in self.zone_id:
            self.timer["act"] += elapsed

    # -- output

    def timers(self) -> dict:
        return {
            "timer": format_seconds(self.timer["total"] + self.timer["act"]),
            "act_timer": f"A{self.timer['act_number']} {format_seconds(self.timer['act'])}",
        }

    def snapshot(self) -> dict:
        page = self.pages[self.page]
        lines = visible_lines(page, self.league_start)
        rendered = [self.renderer.render(line, self.act) for line in lines]
        hints = sorted({url for line in lines for url in self.renderer.hints_in(line)})
        preview = []
        for index in range(self.page + 1, len(self.pages)):
            if self.page_ok(index):
                preview = [self.renderer.render(line, self.act)[0] for line in visible_lines(self.pages[index], self.league_start)[:1]]
                break
        area = self.areas.get(self.zone_id, {})
        xp_text, xp_color = xp_info(self.char_level, self.area_level, self.zone_id)
        return {
            "act": self.act,
            "zone_name": area.get("name", self.zone_id),
            "area_level": self.area_level,
            "char_level": self.char_level,
            "xp": xp_text,
            "xp_color": xp_color,
            "page": self.page,
            "pages": len(self.pages),
            "lines": [{"html": markup, "hint": hint} for markup, hint in rendered],
            "next_lines": preview,
            "hints": hints,
            "recipe": area.get("recipe", ""),
            **self.timers(),
        }


# ------------------------------------------------------------------------ log tail


class LogTail:
    """Follows Client.txt across truncation and inode changes."""

    def __init__(self, path: Path):
        self.path = Path(path)
        self.file = None
        self.ident = None
        self.offset = 0

    def close(self):
        if self.file:
            self.file.close()
        self.file = None

    def _reopen(self) -> bool:
        self.close()
        try:
            self.file = open(self.path, "r", errors="replace")
            stat = os.fstat(self.file.fileno())
        except OSError:
            self.file = None
            return False
        self.ident = (stat.st_dev, stat.st_ino)
        self.offset = 0
        return True

    def read_new(self) -> list[str]:
        """Lines added since the last call; reopens on rotation or truncation."""
        try:
            stat = os.stat(self.path)
        except OSError:
            self.close()
            return []
        if self.file is None or (stat.st_dev, stat.st_ino) != self.ident or stat.st_size < self.offset:
            if not self._reopen():
                return []
        lines = []
        while True:
            line = self.file.readline()
            if not line:
                break
            if not line.endswith("\n"):  # partial line, wait for the writer
                self.file.seek(self.offset)
                break
            self.offset = self.file.tell()
            lines.append(line.rstrip("\n"))
        return lines

    def read_all(self) -> list[str]:
        """Everything currently in the file (startup replay)."""
        if self.file is None and not self._reopen():
            return []
        self.file.seek(0)
        self.offset = 0
        return self.read_new()


# ---------------------------------------------------------------------------- main


def parse_args(argv=None):
    here = Path(__file__).resolve().parent
    state_home = os.environ.get("XDG_STATE_HOME") or str(Path.home() / ".local/state")
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--log", default=os.environ.get("POE_LOG_PATH") or DEFAULT_LOG, help="Client.txt to follow")
    parser.add_argument("--data", default=str(here.parent / "data"), help="directory with guide.json, areas.json, hints/, icons/")
    parser.add_argument("--state", default=f"{state_home}/poe-leveling/state.json", help="progress file")
    parser.add_argument("--league-start", choices=("yes", "no"), default="no", help="league start run (default no)")
    parser.add_argument("--bandit", default="none", choices=("none", "alira", "kraityn", "oak"))
    parser.add_argument("--character", default="", help="only track level-ups of this character")
    return parser.parse_args(argv)


def emit(state: dict):
    print(json.dumps(state), flush=True)


def read_command() -> str | None:
    """One command from stdin, or None when there is nothing to read."""
    if not select.select([sys.stdin], [], [], 0)[0]:
        return None
    line = sys.stdin.readline()
    return line.strip() if line else None


def main(argv=None) -> int:
    args = parse_args(argv)
    data = Path(args.data)
    areas = load_areas(data / "areas.json")
    pages = load_pages(data / "guide.json")
    renderer = Renderer(areas, load_hints(data / "hints"), data / "icons")
    tracker = Tracker(areas, pages, renderer, Path(args.state), args.league_start == "yes", args.bandit)
    log = LogTail(Path(os.path.expanduser(args.log)))

    def handle(line: str, advance: bool = True) -> bool:
        area = AREA_RE.search(line)
        if area:
            tracker.enter_area(area.group(2), int(area.group(1)), advance)
            return True
        level = LEVEL_RE.search(line)
        if level and (not args.character or level.group(1).strip() == args.character):
            tracker.set_level(int(level.group(3)))
            return True
        return False

    # Replay the log once so the panel shows the current zone without advancing pages.
    for line in log.read_all():
        handle(line, advance=False)
    emit(tracker.snapshot())

    last_tick = last_save = time.time()
    warned = False
    while True:
        changed = False
        command = read_command()
        if command == "next":
            changed = tracker.step(1)
        elif command == "prev":
            changed = tracker.step(-1)
        elif command == "reset":
            tracker.reset()
            changed = True
        for line in log.read_new():
            changed |= handle(line)
        if changed:
            emit(tracker.snapshot())
        elif not warned and not log.path.exists():
            print(f"waiting for log file: {log.path}", file=sys.stderr)
            warned = True
        now = time.time()
        if now - last_tick >= 1:
            last_tick = now
            tracker.tick()
            emit({"tick": True, **tracker.timers()})
        if now - last_save >= 10:
            last_save = now
            tracker.save_state()
        time.sleep(0.15)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (KeyboardInterrupt, BrokenPipeError):  # parent went away
        sys.exit(0)
