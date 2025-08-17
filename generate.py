#!/usr/bin/env python3
import os
import re
import subprocess
import logging
from pathlib import Path
import pynvim

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

CHEATSHEET = Path.home() / "git/dotfiles/CHEATSHEET.md"

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
        for func in functions:
            func = func.strip()
            if re.match(r'^[a-zA-Z0-9]', func):
                rows.append(f"| function | `{func}` | |")
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

def parse_hyprland_keybindings(path):
    def format_hyprland_keybindings(lines):
        """Format Hyprland keybindings as a markdown table"""
        rows = []
        for line in lines:
            # Parse: bind = SUPER, Return, exec, terminal
            if line.startswith('bind '):
                parts = [p.strip() for p in line.split(',')]
                if len(parts) >= 3:
                    first_part = parts[0].replace('bind =', '').strip()
                    modifier = first_part
                    key = parts[1].strip()
                    action = parts[2].strip()
                    # Get additional args if present
                    if len(parts) > 3:
                        args = ', '.join(parts[3:]).strip()
                        if args:
                            action = f"{action} `{args}`"
                    # Format modifier + key
                    if modifier:
                        key = f"{modifier}+{key}"
                    rows.append(f"| `{key}` | {action} |")
            # Handle binde (continuous) bindings
            elif line.startswith('binde '):
                parts = [p.strip() for p in line.split(',')]
                if len(parts) >= 3:
                    first_part = parts[0].replace('binde =', '').strip()
                    modifier = first_part if first_part else "none"
                    key = parts[1].strip()
                    action = parts[2].strip()
                    if len(parts) > 3:
                        args = ', '.join(parts[3:]).strip()
                        action = f"{action} {args}"
                    key_combo = f"{modifier}+{key}"
                    rows.append(f"| `{key_combo}` | {action} (continuous) |")
        table = [
            "| Key | Action |",
            "|-----|--------|",
            *rows
        ]
        return table

    lines = []
    logging.info(f"Parsing Hyprland keybindings from {path}...")
    try:
        with open(path) as f:
            for line in f:
                if re.match(r'^\s*bind( |=)', line):
                    lines.append(line.strip())
        logging.info("Hyprland keybindings parsed.")
    except Exception as e:
        logging.error(f"Error parsing hyprland.conf: {e}")
    return format_hyprland_keybindings(lines)

def get_tldr_summary(cmd):
    logging.info(f"Getting tldr summary for: {cmd}")
    try:
        out = subprocess.check_output(["tldr", "--markdown", cmd], text=True, timeout=2)
        return out.strip()
    except Exception as e:
        logging.warning(f"tldr entry not found for {cmd}: {e}")
        return "_No tldr entry_"

def main():
    logging.info(f"Writing cheatsheet to {CHEATSHEET}")
    with open(CHEATSHEET, "w") as f:
        f.write("# Zsh Aliases & Functions\n")
        for line in parse_zsh_aliases_functions():
            f.write(line + "\n")
        f.write("\n")

        f.write("# Tmux Keybindings\n")
        for line in parse_tmux_keybindings("tmux/.tmux.conf"):
            f.write(line + "\n")
        f.write("\n")

        f.write("# Hyprland Keybindings\n")
        for line in parse_hyprland_keybindings("hyprland/.config/hypr/hyprland.conf"):
            f.write(line + "\n")
        f.write("\n")

        f.write("# Neovim Keybindings\n")
        for line in get_neovim_leader_keymaps():
            f.write(line + "\n")
        f.write("\n")

        for cmd in ["ls", "grep", "tmux", "nvim", "git", "docker", "yay"]:
            f.write(get_tldr_summary(cmd) + "\n\n")
    logging.info("Cheatsheet generation complete.")

if __name__ == "__main__":
    main()
