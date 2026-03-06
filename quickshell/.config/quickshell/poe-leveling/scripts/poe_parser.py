#!/usr/bin/env python3

import json
import re
import sys
import time
from pathlib import Path
from typing import Any, Dict, List


def load_zones(zones_file: Path) -> Dict[str, Dict[str, Any]]:
    """Load zones from areas JSON (original Exile-UI format)."""
    with open(zones_file) as f:
        acts = json.load(f)

    zones = {}
    for act_idx, act in enumerate(acts, start=1):
        for zone in act:
            zone_id = zone["id"]
            zones[zone_id] = {
                "id": zone_id,
                "name": zone["name"],
                "act": act_idx,
                "recommendation": zone.get("recommendation", "").split("|")
                if "recommendation" in zone
                else [],
            }

    return zones


def load_guide(guide_file: Path) -> Dict[str, List[Any]]:
    """
    Load guide from default guide JSON (original Exile-UI format).

    Maps zone_id -> entries to show when IN that zone.
    Following Exile-UI's sequential logic: when you enter a zone, it shows
    the NEXT entry after the one that targeted that zone.
    Falls back to showing the targeting entry itself if no next entry exists.
    """
    with open(guide_file) as f:
        acts = json.load(f)

    # Flatten all entries across acts into a sequential list
    all_entries = []
    for act in acts:
        for entry in act:
            # Handle conditional entries
            if isinstance(entry, dict) and "condition" in entry:
                entry = entry["lines"]
            if isinstance(entry, list) and len(entry) > 0:
                all_entries.append(entry)

    # Build map: zone_id -> entries to show when IN that zone
    guide = {}
    for i, entry in enumerate(all_entries):
        # Find the LAST zone ID mentioned in any line
        # Patterns: "enter areaid{zone}", "to areaid{zone}", "road: areaid{zone}", etc.
        target_zone = None
        for line in entry:
            # Look for areaid{zone} with optional preceding context (enter, to, word:, etc.)
            match = re.search(r"areaid(\d+_\d+_?\w*|g\d+_(?:\d+_)?\d+[a-z]?)", line)
            if match:
                target_zone = match.group(1)  # Keep updating to get the LAST one

        # When you enter target_zone, show the NEXT entry (or this entry as fallback)
        if target_zone:
            if target_zone not in guide:
                guide[target_zone] = []

            # Prefer the next entry
            if i + 1 < len(all_entries):
                guide[target_zone].append(all_entries[i + 1])
            else:
                # Fallback: show the entry that mentions entering this zone
                guide[target_zone].append(entry)

    return guide


def load_hint_images(hints_dir: Path) -> List[str]:
    """Load list of available hint image filenames (without extension)."""
    if not hints_dir.exists():
        return []

    hints = []
    for img in hints_dir.glob("*.jpg"):
        hints.append(img.stem)
    for img in hints_dir.glob("*.png"):
        hints.append(img.stem)

    return hints


def load_quests(gems_file: Path) -> tuple[Dict[str, Dict[str, Any]], Dict[str, Any]]:
    """Load quest information and gems data from gems JSON file."""
    with open(gems_file) as f:
        data = json.load(f)

    # Extract the _quests section which has quest info
    quests = data.get("_quests", {})

    # Convert quest names to title case for display
    quest_display = {}
    for quest_key, quest_info in quests.items():
        # Convert key like "the_caged_brute1" to display format
        quest_display[quest_key] = {
            "name": quest_key.replace("_", " ").title().rstrip("0123456789"),
            "act": quest_info.get("act", ""),
            "npc": quest_info.get("npc", "").title(),
        }

    return quest_display, data


def get_gems_for_quest(quest_key: str, gems_data: Dict[str, Any]) -> List[str]:
    """Get list of gems available from a quest (as quest rewards, not vendor)."""
    gems = []
    for gem_name, gem_info in gems_data.items():
        if gem_name.startswith("_"):
            continue
        if "quests" not in gem_info:
            continue
        if quest_key in gem_info["quests"]:
            quest_data = gem_info["quests"][quest_key]
            # Only include if it's a quest reward (has 'quest' key with classes)
            if "quest" in quest_data and quest_data["quest"]:
                gems.append(gem_name)
    return sorted(gems)


def format_line(
    line: str,
    zones: Dict[str, Dict[str, Any]] | None = None,
    quests: Dict[str, Dict[str, Any]] | None = None,
    gems_data: Dict[str, Any] | None = None,
) -> str:
    """Simple text replacements for display and resolve area IDs to names."""
    # HTML color codes (Solarized Dark theme)
    COLOR_QUEST = "#DC322F"  # Red (also Strength gems)
    COLOR_WP = "#2AA198"  # Cyan (also towns)
    COLOR_OPTIONAL = "#859900"  # Green (also Dexterity gems)
    COLOR_WARNING = "#B58900"  # Yellow
    COLOR_INT = "#268BD2"  # Blue for Intelligence gems

    # First, resolve area IDs to zone names with colorization
    if zones:
        area_pattern = r"areaid(\d+_\d+_?\w*)"

        def replace_area_id(match):
            area_id = match.group(1)
            if area_id in zones:
                zone_name = zones[area_id]["name"]
                # Colorize towns
                if "_town" in area_id:
                    return f'<span style="color:{COLOR_WP}">{zone_name}</span>'
                else:
                    return zone_name
            return match.group(0)

        line = re.sub(area_pattern, replace_area_id, line)

    # Resolve quest tags like <the_caged_brute1> to gem list
    if quests and gems_data:
        quest_tag_pattern = r"<([a-z_0-9']+)>"

        def shorten_gem_name(gem_name: str) -> str:
            """Shorten gem names by removing common words."""
            name = gem_name
            name = name.replace(" support", "")
            name = name.replace(" damage", "")
            name = name.replace("additional ", "add. ")
            return name

        def colorize_gem(gem_name: str) -> str:
            """Colorize gem by attribute - returns HTML."""
            if gem_name not in gems_data or "_" in gem_name[0]:
                return gem_name

            short_name = shorten_gem_name(gem_name)
            gem_info = gems_data[gem_name]
            attribute = gem_info.get("attribute", 0)

            if attribute == 1:  # Strength
                return f'<span style="color:{COLOR_QUEST}">{short_name}</span>'
            elif attribute == 2:  # Dexterity
                return f'<span style="color:{COLOR_OPTIONAL}">{short_name}</span>'
            elif attribute == 3:  # Intelligence
                return f'<span style="color:{COLOR_INT}">{short_name}</span>'
            return short_name

        def replace_quest_tag(match):
            quest_key_with_underscores = match.group(1)
            quest_key = quest_key_with_underscores.replace("_", " ")
            if quest_key in quests:
                gems = get_gems_for_quest(quest_key, gems_data)
                if gems:
                    # Colorize and show ALL gems (no limit)
                    colored_gems = [colorize_gem(gem) for gem in gems]
                    gem_list = ", ".join(colored_gems)
                    return gem_list
                else:
                    quest_info = quests[quest_key]
                    return f'"{quest_info["name"]}"'
            return match.group(0)

        line = re.sub(quest_tag_pattern, replace_quest_tag, line)

    # Handle (quest:item_name) tags
    quest_pattern = r"\(quest:([^)]+)\)"

    def replace_quest(match):
        item_name = match.group(1).replace("_", " ")
        return f'<span style="color:{COLOR_QUEST}">{item_name}</span>'

    result = re.sub(quest_pattern, replace_quest, line)

    # Icon replacements with HTML coloring
    replacements = {
        "(img:waypoint)": f'<span style="color:{COLOR_WP}">[WP]</span>',
        "(img:quest_2)": f'<span style="color:{COLOR_QUEST}">[QUEST]</span>',
        "(img:quest)": f'<span style="color:{COLOR_QUEST}">[QUEST]</span>',
        "(img:portal)": f'<span style="color:{COLOR_OPTIONAL}">[PORTAL]</span>',
        "(img:checkpoint)": "[CP]",
        "(img:skill)": "[SKILL]",
        "(img:support)": "[SUPPORT]",
        "(img:in-out2)": "[IN/OUT]",
        "(img:town)": "[TOWN]",
        "(img:arena)": "[ARENA]",
        "(img:exa)": "[EXA]",
        "(img:regal)": "[REGAL]",
        "(img:ring)": "[RING]",
        "(img:hideout)": "[HIDEOUT]",
        "(img:lab)": f'<span style="color:{COLOR_WARNING}">[LAB]</span>',
        "(img:craft)": "[CRAFT]",
        "(img:0)": f'<span style="color:{COLOR_WP}">↑</span>',
        "(img:1)": f'<span style="color:{COLOR_WP}">↗</span>',
        "(img:2)": f'<span style="color:{COLOR_WP}">→</span>',
        "(img:3)": f'<span style="color:{COLOR_WP}">↘</span>',
        "(img:4)": f'<span style="color:{COLOR_WP}">↓</span>',
        "(img:5)": f'<span style="color:{COLOR_WP}">↙</span>',
        "(img:6)": f'<span style="color:{COLOR_WP}">←</span>',
        "(img:7)": f'<span style="color:{COLOR_WP}">↖</span>',
        "(color:red)": "",
        "(color:cc99ff)": "",
        "(color:ff00ff)": "",
        "(color:ffffff)": "",
        "(color:fec076)": "",
        "(color:aqua)": "",
        "(hint)__": "  →",
        "(hint)_": "  →",
        " ;; ": " → ",
        ";;": " →",
        "||": " OR ",
    }

    for old, new in replacements.items():
        result = result.replace(old, new)

    # Clean up extra spaces
    result = re.sub(r"\s+", " ", result)
    return result.strip()


def extract_hints(lines: List[str], available_hints: List[str]) -> List[str]:
    """
    Extract hint image references from guide lines by matching text to available images.
    This dynamically finds hints by looking for image names in the text.
    """
    if not available_hints:
        return []

    hints = []
    text = " ".join(lines).lower()

    # Try to match each available hint image name in the text
    for hint_name in available_hints:
        # Convert hint filename to searchable patterns
        # e.g., "1st_corridor" -> ["1st corridor", "1st_corridor"]
        #       "diamond-shape" -> ["diamond-shape", "diamond shape"]
        patterns = [
            hint_name.replace("_", " "),  # underscores to spaces
            hint_name.replace("-", " "),  # dashes to spaces
            hint_name,  # original
        ]

        # Check if any pattern matches
        for pattern in patterns:
            if pattern.lower() in text:
                hints.append(f"{hint_name}.jpg")
                break

    return hints


def tail_file(filepath: Path):
    """Tail a file and yield new lines. Wait for file if it doesn't exist."""
    # Wait for file to exist
    while not filepath.exists():
        print(f"Waiting for log file: {filepath}", file=sys.stderr)
        time.sleep(1)

    print(f"Log file found, starting to tail...", file=sys.stderr)

    try:
        with open(filepath) as f:
            # Always seek to end for tailing - we'll scan the file separately on startup
            file_size = filepath.stat().st_size
            print(
                f"Log file size: {file_size} bytes, tailing from end",
                file=sys.stderr,
            )
            f.seek(0, 2)  # Go to end

            while True:
                line = f.readline()
                if line:
                    yield line.strip()
                else:
                    time.sleep(0.1)
    except Exception as e:
        print(f"ERROR reading log file: {e}", file=sys.stderr)
        sys.exit(1)


def scan_file_for_current_zone(
    filepath: Path,
    zones: Dict,
    guide: Dict,
    quests: Dict,
    gems_data: Dict,
    available_hints: List[str],
) -> Dict[str, Any] | None:
    """Scan the entire file to find the most recent zone change."""
    print(f"Scanning {filepath} for current zone...", file=sys.stderr)

    try:
        with open(filepath) as f:
            last_zone_state = None
            for line in f:
                state = parse_zone_change(
                    line.strip(), zones, guide, quests, gems_data, available_hints
                )
                if state:
                    last_zone_state = state

            if last_zone_state:
                print(
                    f"  → Found current zone: {last_zone_state['zone_name']}",
                    file=sys.stderr,
                )
            else:
                print(f"  → No zones found in log", file=sys.stderr)

            return last_zone_state
    except Exception as e:
        print(f"ERROR scanning log file: {e}", file=sys.stderr)
        return None


def parse_zone_change(
    line: str,
    zones: Dict,
    guide: Dict,
    quests: Dict,
    gems_data: Dict,
    available_hints: List[str],
) -> Dict[str, Any] | None:
    """Parse a zone change from log line."""
    # Pattern: Generating level X area "Zone Name" or area ID
    match = re.search(r'Generating level (\d+) area "([^"]+)"', line)
    if not match:
        return None

    level = int(match.group(1))
    zone_identifier = match.group(2)

    # Find zone - could be zone ID (e.g., "1_1_7_1") or zone name
    zone_id = None
    zone_info = None

    # First try as zone ID (direct lookup)
    if zone_identifier in zones:
        zone_id = zone_identifier
        zone_info = zones[zone_identifier]
    else:
        # Try as zone name (case-insensitive search)
        zone_name_lower = zone_identifier.lower()
        for zid, zdata in zones.items():
            if zdata["name"].lower() == zone_name_lower:
                zone_id = zid
                zone_info = zdata
                break

    if not zone_id or not zone_info:
        return None

    # Get guide entries for this zone
    guide_entries = guide.get(zone_id, [])
    formatted_lines = []
    all_hints = []

    for entry in guide_entries:
        for line in entry:
            formatted = format_line(
                line, zones, quests, gems_data
            )  # Pass zones, quests, and gems_data
            if formatted:
                formatted_lines.append(formatted)
        # Extract hints dynamically by matching text to available images
        all_hints.extend(extract_hints(entry, available_hints))

    # Parse recommendation field (format: "min | max" or "min | rec | max")
    # PoE1 doesn't have recommendations, PoE2 does
    recommendation_display = None
    if zone_info.get("recommendation"):
        rec_parts = [p.strip() for p in zone_info["recommendation"].split("|")]
        if len(rec_parts) >= 2:
            # Display as "min | current | max" (insert current level)
            recommendation_display = f"{rec_parts[0]} | {level} | {rec_parts[-1]}"

    return {
        "zone_id": zone_id,
        "zone_name": zone_info["name"],  # Already properly cased in PoE1 data
        "act": zone_info["act"],
        "level": level,
        "recommendation": recommendation_display,  # Formatted level range (or None for PoE1)
        "guide": formatted_lines,
        "hints": list(set(all_hints)),  # Remove duplicates
    }


def main():
    if len(sys.argv) != 5:
        print("Usage: poe_parser.py <client.txt> <guide.json> <areas.json> <gems.json>")
        sys.exit(1)

    log_file = Path(sys.argv[1])
    guide_file = Path(sys.argv[2])
    zones_file = Path(sys.argv[3])
    gems_file = Path(sys.argv[4])

    # Determine hints directory (assumes it's in same dir as guide.json)
    hints_dir = guide_file.parent / "hints"

    # Load data
    print(f"Loading zones from {zones_file}...", file=sys.stderr)
    zones = load_zones(zones_file)
    print(f"  → Loaded {len(zones)} zones", file=sys.stderr)

    print(f"Loading guide from {guide_file}...", file=sys.stderr)
    guide = load_guide(guide_file)
    print(f"  → Loaded {len(guide)} guide entries", file=sys.stderr)

    print(f"Loading quests from {gems_file}...", file=sys.stderr)
    quests, gems_data = load_quests(gems_file)
    print(f"  → Loaded {len(quests)} quest rewards", file=sys.stderr)

    print(f"Loading hint images from {hints_dir}...", file=sys.stderr)
    available_hints = load_hint_images(hints_dir)
    print(f"  → Found {len(available_hints)} hint images", file=sys.stderr)

    print(f"Watching log file: {log_file}", file=sys.stderr)

    # First, scan the entire file to find the current zone
    current_zone = scan_file_for_current_zone(
        log_file, zones, guide, quests, gems_data, available_hints
    )
    if current_zone:
        # Emit current zone state immediately
        print(json.dumps(current_zone), flush=True)

    # Then tail the file for new zone changes
    for line in tail_file(log_file):
        state = parse_zone_change(
            line, zones, guide, quests, gems_data, available_hints
        )
        if state:
            # Emit JSON state to stdout
            print(json.dumps(state), flush=True)


if __name__ == "__main__":
    main()
