from pathlib import Path
import re

SCRIPT_DIR = Path(__file__).parent.parent.resolve()
CONFIG_PATH = SCRIPT_DIR / "hyprland" / ".config" / "hypr" / "hyprland.conf"
OUTPUT_PATH = SCRIPT_DIR / "bin" / ".local" / "bin" / "menu-actions.conf"

SKIP_BINDINGS = [ "print" ]

with open(CONFIG_PATH) as f, open(OUTPUT_PATH, "w") as out:
    def write_action(name, cmd, comment):
        action_name = comment if comment else name
        out.write(f"{action_name}:{cmd}\n")

    pattern = re.compile(
        r'bind\s*=\s*SUPER(?:_SHIFT)?,\s*([^\s,]+),\s*(exec|togglespecialworkspace),\s*(.+)'
    )

    for line in f:
        comment = ""
        if "#" in line:
            split = line.split("#", 1)
            line = split[0].strip()
            comment = split[1].strip()

        m = pattern.match(line)
        if m:
            key, action, value = m.groups()
            if action == "exec":
                if key.lower() in SKIP_BINDINGS:
                    continue
                cmd = f"{value.strip()}"
                write_action(key, cmd, comment)
            elif action == "togglespecialworkspace":
                cmd = f"hyprctl dispatch togglespecialworkspace {value.strip()}"
                write_action(value, cmd, comment)
