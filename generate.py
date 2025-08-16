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

        # Regex: mode, keys, optional '*', Lua location, description
        keymap_re = re.compile(r'^([nvxi])\s+(<Space>[^\s]*)\s+\*?\s+<Lua [^>]+>\s*(.*)')
        combos = defaultdict(set)  # (keys, desc) -> set(modes)

        for line in raw_lines:
            m = keymap_re.match(line)
            if m:
                mode = m.group(1)
                keys = m.group(2)
                desc = m.group(3)
                combos[(keys, desc)].add(mode)

        # Sort by description, then keys
        sorted_items = sorted(combos.items(), key=lambda x: (x[0][1], x[0][0]))
        result = []
        for (keys, desc), modes in sorted_items:
            mode_str = "".join(sorted(modes))
            result.append(f"**{mode_str}** `{keys}`: {desc}")
        return result

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

def parse_zsh_aliases_functions(path):
    def format_zsh_aliases(lines):
        """Format zsh aliases and functions for better readability"""
        formatted = []
        for line in lines:
            if line.startswith('alias '):
                # Extract alias name and value
                match = re.match(r'alias\s+([^=]+)=(.+)', line)
                if match:
                    name, value = match.groups()
                    value = value.strip('\'"')
                    formatted.append(f"`{name}`: {value}")
            elif line.startswith('function '):
                # Extract function name
                match = re.match(r'function\s+([^{\s]+)', line)
                if match:
                    name = match.group(1).strip()
                    if name and name != "()":
                        formatted.append(f"`{name}`: function")
        return sorted(formatted)

    lines = []
    logging.info(f"Parsing zsh aliases/functions from {path}...")
    try:
        with open(path) as f:
            for line in f:
                if re.match(r'^\s*alias ', line) or re.match(r'^\s*function ', line):
                    lines.append(line.strip())
        logging.info("Zsh aliases/functions parsed.")
    except Exception as e:
        logging.error(f"Error parsing zshrc: {e}")

    return format_zsh_aliases(lines)

def parse_tmux_keybindings(path):
    def format_tmux_keybindings(lines):
        """Format tmux keybindings for better readability"""
        formatted = []
        for line in lines:
            # Parse different bind formats
            if line.startswith('bind '):
                parts = line.split()
                if parts[1] == '-T':
                    mode = parts[2]
                    key = parts[3]
                    action = ' '.join(parts[4:])
                    formatted.append(f"`{key}` ({mode}): {action}")
                    continue
                elif parts[1].startswith('-'):
                    parts = parts[1:]

                key = parts[1]
                action = parts[2]
                args = ''
                if len(parts) > 3:
                    args = ' '.join(parts[3:])
                    args = args.replace('"', '').replace("'", "").replace('`', '')
                    args = '`' + args.strip() + '`'
                formatted.append(f"`{key}`: {action} {args}".strip())

        return sorted(formatted)

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
        """Format Hyprland keybindings for better readability"""
        formatted = []
        for line in lines:
            # Parse: bind = SUPER, Return, exec, terminal
            if line.startswith('bind '):
                parts = [p.strip() for p in line.split(',')]
                if len(parts) >= 3:
                    # Extract modifier and key from first part
                    first_part = parts[0].replace('bind =', '').strip()
                    modifier = first_part
                    key = parts[1].strip()
                    action = parts[2].strip()

                    # Get additional args if present
                    if len(parts) > 3:
                        args = ', '.join(parts[3:]).strip()
                        action = f"{action} `{args}`"

                    # Format modifier + key
                    if modifier:
                        key = f"{modifier}+{key}"

                    formatted.append(f"`{key}`: {action}")

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
                    formatted.append(f"`{key_combo}`: {action} (continuous)")

        return sorted(formatted)

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
        out = subprocess.check_output(["tldr", cmd], text=True, timeout=2)
        return out.strip()
    except Exception as e:
        logging.warning(f"tldr entry not found for {cmd}: {e}")
        return "_No tldr entry_"

def main():
    logging.info(f"Writing cheatsheet to {CHEATSHEET}")
    with open(CHEATSHEET, "w") as f:
        f.write("# System Cheatsheet\n\n")

        f.write("## Zsh Aliases & Functions\n")
        for line in parse_zsh_aliases_functions("zsh/.zshrc"):
            f.write(line + "  \n")
        f.write("\n")

        f.write("## Tmux Keybindings\n")
        for line in parse_tmux_keybindings("tmux/.tmux.conf"):
            f.write(line + "  \n")
        f.write("\n")

        f.write("## Hyprland Keybindings\n")
        for line in parse_hyprland_keybindings("hyprland/.config/hypr/hyprland.conf"):
            f.write(line + "  \n")
        f.write("\n")

        f.write("## Neovim <leader> Keybindings\n")
        for line in get_neovim_leader_keymaps():
            f.write(line + "  \n")
        f.write("\n")

        f.write("## Common Commands (tldr)\n")
        for cmd in ["ls", "grep", "tmux", "nvim", "git", "docker", "yay", "pacman"]:
            f.write(f"### {cmd}\n")
            f.write(get_tldr_summary(cmd) + "\n\n")
    logging.info("Cheatsheet generation complete.")

if __name__ == "__main__":
    main()
