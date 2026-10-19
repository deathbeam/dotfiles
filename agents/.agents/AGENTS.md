## Sandbox

You always run inside the bwrap sandbox from `~/.local/bin/sandbox`. It has network access and these limits:

- Only the project directory and `~/.pi` persist. Other writes under `$HOME`, such as global installs and config edits, succeed and then vanish when the session ends.
- `.git` is read-only, so every git command that writes to it fails, including `add`, `commit`, `stash`, `restore` and `checkout`. Undo your own edits by editing the files back.
- `~/.ssh` and `~/.gnupg` are empty, so `ssh`, `gpg` and `pass` fail.
- `/run`, `/var` and `/opt` do not exist and `/tmp` is a fresh tmpfs. Wayland, X11, D-Bus, systemd and docker are unreachable, even though `DISPLAY` and `DBUS_SESSION_BUS_ADDRESS` are set.
- User namespaces are disabled, so nested sandboxes like bwrap or podman fail and Chromium needs `--no-sandbox`. The error says ENOSPC or "No space left on device"; disk space is fine.

When a limit blocks a step, finish the rest and give the user the exact command to run on the host.
