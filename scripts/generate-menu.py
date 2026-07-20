#!/usr/bin/env python3
"""Generate menu-actions.conf from live Hyprland keybinds (hyprctl binds -j)."""
import json
import subprocess
import logging
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

SCRIPT_DIR = Path(__file__).parent.parent.resolve()
OUTPUT_PATH = SCRIPT_DIR / "bin" / ".local" / "bin" / "menu-actions.conf"

# modmask bit flags (X11/evdev convention, as reported by hyprctl binds -j)
#   bit 0 (1)  -> SHIFT
#   bit 6 (64) -> SUPER (Logitech/Mod4)
# We only surface binds whose *only* modifier is SUPER, optionally + SHIFT.
SHIFT_BIT = 1 << 0
SUPER_BIT = 1 << 6

# Keys whose exec command we don't want to expose in the menu.
SKIP_KEYS = {"print"}

# Dispatchers not useful as menu entries.
SKIP_DISPATCHERS = {
    "submap", "mouse", "exit", "killactive",
    "togglefloating", "togglegroup", "fullscreen",
    "movefocus", "movewindoworgroup", "resizeactive", "moveactive",
    "workspace", "movetoworkspace",
}


def hyprctl_binds():
    """Return the parsed `hyprctl binds -j` list, or [] on failure."""
    try:
        out = subprocess.check_output(["hyprctl", "binds", "-j"], text=True)
        return json.loads(out)
    except Exception as e:
        logging.error(f"Could not query hyprctl binds: {e}")
        return []


def toggle_special_cmd(name: str) -> str:
    """togglespecialworkspace command valid under both legacy and lua configs."""
    escaped = name.replace('"', '\\"')
    lua = f"hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"{escaped}\")'"
    legacy = f"hyprctl dispatch togglespecialworkspace {name}"
    return f"{lua} || {legacy}"


def key_label(key: str) -> str:
    """Human-friendly menu label for a key name."""
    if key == "space":
        return "space"
    return key


def main():
    binds = hyprctl_binds()
    rows = []

    for b in binds:
        dispatcher = b.get("dispatcher", "")
        modmask = int(b.get("modmask", 0))
        key = b.get("key", "")
        arg = b.get("arg", "")

        # Only SUPER (+ optional SHIFT) binds belong in the actions menu.
        if not (modmask & SUPER_BIT):
            continue
        extra_bits = modmask & ~(SUPER_BIT | SHIFT_BIT)
        if extra_bits:
            continue  # has other modifiers (CTRL/ALT/etc.) — skip
        has_shift = bool(modmask & SHIFT_BIT)

        if key.lower() in SKIP_KEYS:
            continue
        if dispatcher in SKIP_DISPATCHERS:
            continue

        # Skip submap-internal binds.
        if b.get("submap"):
            continue

        if dispatcher == "exec":
            cmd = arg.strip()
            # Prefer the bind's `description` flag, then -p value, then # comment, then key.
            label = b.get("description", "")
            if not label:
                import re as _re
                m = _re.search(r'-p\s+"([^"]+)"', arg)
                if m:
                    label = m.group(1)
            if not label:
                label = arg.split("#", 1)[-1].strip() if "#" in arg else ""
            if not label:
                label = key_label(key)
            # Skip legacy hyprctl-dispatch shell-script binds (break under lua config).
            if cmd.startswith("hyprctl dispatch"):
                continue
        elif dispatcher == "togglespecialworkspace":
            name = arg.strip()
            if not name:
                continue  # unnamed/default special — no useful menu label
            cmd = toggle_special_cmd(name)
            label = b.get("description", "") or name
        else:
            # Unknown dispatcher — skip rather than emit something broken.
            continue

        if not cmd:
            continue

        prefix = "SUPER_SHIFT+" if has_shift else "SUPER+"
        name = f"{prefix}{key}" if label == "" else label
        rows.append((name, cmd, label))

    with open(OUTPUT_PATH, "w") as out:
        for name, cmd, label in rows:
            action_name = label if label else name
            out.write(f"{action_name}:{cmd}\n")

    logging.info(f"Wrote {len(rows)} actions to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
