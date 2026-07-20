#!/usr/bin/env python3
import re
import subprocess
import logging
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

SCRIPT_DIR = Path(__file__).parent.parent.resolve()
CHEATSHEET = SCRIPT_DIR / "CHEATSHEET.md"

def get_neovim_leader_keymaps():
    def format_leader_keymaps(raw_lines):
        from collections import defaultdict

        keymap_re = re.compile(r'^([nvxi])\s+(<Space>[^\s]*)\s+\*?\s+<Lua [^>]+>\s*(.*)')
        combos = defaultdict(set)  # (keys, desc) -> set(modes)
        desc_map = {}

        for line in raw_lines:
            m = keymap_re.match(line)
            if m:
                mode = m.group(1)
                keys = m.group(2)
                desc = m.group(3)
                combos[(keys, desc)].add(mode)
                desc_map[(keys, desc)] = desc

        # Prepare table rows
        rows = []
        for (keys, desc), modes in sorted(combos.items(), key=lambda x: (x[0][1], x[0][0])):
            mode_str = "".join(sorted(modes))
            rows.append(f"| {mode_str} | `{keys}` | {desc} |")
        # Table header
        table = [
            "| Mode | Key | Description |",
            "|------|-----|-------------|",
            *rows
        ]
        return table

    keymaps = []
    vim_cmds = [
        "nmap <leader>",
        "vmap <leader>",
        "xmap <leader>",
        "imap <leader>"
    ]
    try:
        logging.info("Extracting Neovim <leader> keymaps using :map commands...")
        result = subprocess.run(
            ["nvim", "--headless"] +
            sum([["-c", cmd] for cmd in vim_cmds], []) +
            ["+qall"],
            text=True, timeout=5, capture_output=True
        )

        out = result.stdout.strip() + "\n" + result.stderr.strip()
        formatted = []
        buffer = []
        keymap_re = re.compile(r'^[nvxi]\s+<.*>')

        for line in out.splitlines():
            if keymap_re.match(line):
                if buffer:
                    formatted.append(" ".join(buffer))
                    buffer = []
                buffer.append(line.strip())
            elif line.strip():
                buffer.append(line.strip())
        if buffer:
            formatted.append(" ".join(buffer))
        return format_leader_keymaps(formatted)
    except Exception as e:
        logging.error(f"Error extracting Neovim keymaps: {e}")
        keymaps.append(f"(Error: {e})")
    return keymaps

def parse_zsh_aliases_functions():
    def format_zsh_items(aliases, functions):
        """Format zsh aliases and functions as a markdown table"""
        rows = []
        # Format aliases
        for alias in aliases:
            alias = alias.strip()
            if re.match(r'^[a-zA-Z0-9]', alias) and not alias.startswith('base16'):
                split = alias.split('=', 1)
                key = split[0].strip()
                value = split[1].strip().replace('"', '').replace("'", "").replace('`', '').replace("|", "\\|")
                rows.append(f"| alias | `{key}` | `{value}`")
        # Format functions
        # for now skip functions
        # for func in functions:
        #     func = func.strip()
        #     if re.match(r'^[a-zA-Z0-9]', func):
        #         rows.append(f"| function | `{func}` | |")
        table = [
            "| Type | Name | Value |",
            "|------|------|-------|",
            *rows
        ]
        return table

    aliases = []
    functions = []
    logging.info("Getting zsh aliases and functions...")

    try:
        # Get aliases
        result = subprocess.run(
            ["zsh", "-ic", "alias"],
            text=True, timeout=5, capture_output=True
        )
        if result.stdout:
            aliases = [line for line in result.stdout.strip().split('\n') if line.strip()]

        # Get function names only
        result = subprocess.run(
            ["zsh", "-ic", "print -l ${(k)functions}"],
            text=True, timeout=5, capture_output=True
        )
        if result.stdout:
            functions = [line for line in result.stdout.strip().split('\n') if line.strip()]

        logging.info("Zsh aliases/functions retrieved.")
    except Exception as e:
        logging.error(f"Error getting zsh aliases/functions: {e}")

    return format_zsh_items(aliases, functions)

def parse_tmux_keybindings(path):
    def format_tmux_keybindings(lines):
        """Format tmux keybindings as a markdown table"""
        rows = []
        for line in lines:
            # Parse different bind formats
            if line.startswith('bind '):
                parts = line.split()
                if parts[1] == '-T':
                    mode = parts[2]
                    key = parts[3]
                    action = ' '.join(parts[4:])
                    rows.append(f"| `{mode}` | `{key}` | {action} |")
                    continue
                elif parts[1].startswith('-'):
                    parts = parts[1:]

                key = parts[1]
                action = parts[2]
                args = ''
                if len(parts) > 3:
                    args = ' '.join(parts[3:])
                    args = args.replace('"', '').replace("'", "").replace('`', '')
                    args = f"`{args.strip()}`"
                rows.append(f"| | `{key}` | {action} {args}".strip())
        table = [
            "| Mode | Key | Action |",
            "|------|-----|--------|",
            *rows
        ]
        return table

    lines = []
    logging.info(f"Parsing tmux keybindings from {path}...")
    try:
        with open(path) as f:
            for line in f:
                if re.match(r'^\s*bind', line):
                    lines.append(line.strip())
        logging.info("Tmux keybindings parsed.")
    except Exception as e:
        logging.error(f"Error parsing tmux.conf: {e}")
    return format_tmux_keybindings(lines)

def parse_hyprland_keybindings():
    """Format Hyprland keybindings as a markdown table, via hyprctl binds -j."""
    import json
    import subprocess as _sp

    SHIFT_BIT = 1 << 0
    SUPER_BIT = 1 << 6

    # Maps a (dispatcher, arg) pair to a short human-readable action string.
    # Anything not listed here falls back to the dispatcher name + arg.
    def action_for(dispatcher, arg):
        a = arg.strip()
        if dispatcher == "exec":
            # Preserve any trailing comment as a hint, e.g. `cmd  # label`.
            if "#" in a:
                return f"exec `{a.split('#', 1)[0].strip()}  # {a.split('#', 1)[1].strip()}`"
            return f"exec `{a}`"
        if dispatcher == "togglespecialworkspace":
            return f"togglespecialworkspace `{a}`"
        if dispatcher == "workspace":
            return f"workspace `{a}`"
        if dispatcher == "movetoworkspace":
            return f"movetoworkspace `{a}`"
        if dispatcher == "movefocus":
            return f"movefocus `{a}`"
        if dispatcher == "movewindoworgroup":
            return f"movewindoworgroup `{a}`"
        if dispatcher == "fullscreen":
            return f"fullscreen `{a}`" if a else "fullscreen"
        if dispatcher == "submap":
            return f"submap `{a}`"
        if dispatcher == "mouse":
            return f"{a}" if a else "mouse"
        if dispatcher == "killactive":
            return "killactive"
        if dispatcher == "togglefloating":
            return "togglefloating"
        if dispatcher == "togglegroup":
            return "togglegroup"
        if dispatcher == "exit":
            return "exit"
        if dispatcher == "resizeactive":
            return f"resizeactive `{a}`"
        if dispatcher == "moveactive":
            return f"moveactive `{a}`"
        return f"{dispatcher} `{a}`".strip()

    def key_combo(modmask, key):
        mods = []
        if modmask & SUPER_BIT:
            mods.append("SUPER")
        if modmask & SHIFT_BIT:
            mods.append("SHIFT")
        # Other modifiers (CTRL/ALT) are kept verbatim for completeness.
        if modmask & (1 << 2):
            mods.append("CTRL")
        if modmask & (1 << 3):
            mods.append("ALT")
        mods.append(key)
        return "+".join(mods)

    try:
        out = _sp.check_output(["hyprctl", "binds", "-j"], text=True)
        binds = json.loads(out)
        logging.info("Hyprland keybindings parsed from live instance.")
    except Exception as e:
        logging.error(f"Error querying hyprctl binds: {e}")
        return ["| Key | Action |", "|-----|--------|"]

    rows = []
    for b in binds:
        dispatcher = b.get("dispatcher", "")
        # Skip mouse binds (handled separately / not keyboard-relevant for a cheatsheet).
        if b.get("mouse"):
            continue
        # Skip submap-internal binds to keep the cheatsheet focused on global binds.
        if b.get("submap"):
            continue
        key = b.get("key", "")
        modmask = int(b.get("modmask", 0))
        arg = b.get("arg", "")
        action = action_for(dispatcher, arg)
        rows.append(f"| `{key_combo(modmask, key)}` | {action} |")

    return ["| Key | Action |", "|-----|--------|", *rows]

def get_tldr_summary(cmd):
    logging.info(f"Getting tldr summary for: {cmd}")
    try:
        out = subprocess.check_output(["tldr", "--markdown", cmd], text=True, timeout=2)
        return "#" + out.strip()
    except Exception as e:
        logging.warning(f"tldr entry not found for {cmd}: {e}")
        return "_No tldr entry_"

def main():
    logging.info(f"Writing cheatsheet to {CHEATSHEET}")
    with open(CHEATSHEET, "w") as f:
        f.write("# Hyprland Keybindings\n")
        for line in parse_hyprland_keybindings():
            f.write(line + "\n")
        f.write("\n")

        f.write("# Tmux Keybindings\n")
        for line in parse_tmux_keybindings(SCRIPT_DIR / "tmux/.tmux.conf"):
            f.write(line + "\n")
        f.write("\n")

        f.write("# Neovim Keybindings\n")
        for line in get_neovim_leader_keymaps():
            f.write(line + "\n")
        f.write("\n")

        f.write("# Zsh Aliases\n")
        for line in parse_zsh_aliases_functions():
            f.write(line + "\n")
        f.write("\n")

        f.write("# Useful Commands\n")
        for cmd in ["yay", "git", "docker", "rg", "kubectl"]:
            f.write(get_tldr_summary(cmd) + "\n\n")
    logging.info("Cheatsheet generation complete.")

if __name__ == "__main__":
    main()
