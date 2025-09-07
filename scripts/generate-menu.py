from pathlib import Path
import re

SCRIPT_DIR = Path(__file__).parent.parent.resolve()
CONFIG_PATH = SCRIPT_DIR / "hyprland" / ".config" / "hypr" / "hyprland.conf"
OUTPUT_PATH = SCRIPT_DIR / "bin" / ".local" / "bin" / "menu-actions.conf"

with open(CONFIG_PATH) as f, open(OUTPUT_PATH, "w") as out:
    for line in f:
        # Extract comment for display name
        comment = ""
        if "#" in line:
            comment = line.split("#", 1)[1].strip()
        # Match exec actions
        m_exec = re.match(r'bind\s*=\s*SUPER(?:_SHIFT)?,\s*([^\s,]+),\s*exec,\s*(.+)', line)
        if m_exec:
            cmd = f"hyprctl dispatch exec {m_exec.group(2).strip()}"
            name = comment if comment else m_exec.group(1)
            out.write(f"{name}:{cmd}\n")
            continue
        # Match togglespecialworkspace actions
        m_toggle = re.match(r'bind\s*=\s*SUPER(?:_SHIFT)?,\s*([^\s,]+),\s*togglespecialworkspace,\s*([^\s,]+)', line)
        if m_toggle:
            cmd = f"hyprctl dispatch togglespecialworkspace {m_toggle.group(2).strip()}"
            name = comment if comment else m_toggle.group(2)
            out.write(f"{name}:{cmd}\n")
