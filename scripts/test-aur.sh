#!/usr/bin/env bash
# Checks installed packages against the list of AUR packages reported to still
# carry malicious ELF binaries.
#
# Source: "AUR Malware that still presents as of now (30 July 2026, 22:00 UTC)"
#   https://lists.archlinux.org/archives/list/aur-general@lists.archlinux.org/thread/P4WIRHTFNH2YZWQHGBAKQWX5YOAFIDLY/
#
# The list lives inline in the mailing-list message as "<pkgname>/<binary>"
# entries (no plain-text URL), so we fetch the thread's mbox.gz export and
# extract the pkgname. A fetch/parse failure aborts loudly (curl -f + pipefail)
# rather than silently reporting CLEAN — a stale list is worse than no list.

set -euo pipefail

LIST_URL='https://lists.archlinux.org/archives/list/aur-general@lists.archlinux.org/export/aur-general@lists.archlinux.org-P4WIRHTFNH2YZWQHGBAKQWX5YOAFIDLY.mbox.gz?thread=P4WIRHTFNH2YZWQHGBAKQWX5YOAFIDLY'

# Fetch + parse the malicious list into a sorted stream of pkgnames. Done
# outside `comm` so a network/parsing failure aborts (set -e + pipefail) instead
# of being swallowed by process-substitution exit codes inside comm.
malicious=$(
    curl -fsSL "$LIST_URL" | gzip -dc |
    perl -nle 'print $1 if /^([a-z0-9][a-z0-9._+-]*)\/[a-z0-9]/' |
    sort -u
)

# Every listed package is AUR (foreign), so only check foreign packages rather
# than the full installed set.
matches=$(comm -12 <(pacman -Qqm | sort) <(printf '%s\n' "$malicious"))

if [ -z "$matches" ]; then
    echo "CLEAN: No compromised packages found."
else
    echo -e "WARNING: Found matches:"
    printf '  %s\n' $matches
    exit 1
fi
