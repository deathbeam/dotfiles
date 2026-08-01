#!/usr/bin/env bash
#
# Blocks an update when an installed AUR package's maintainer changed in a way
# that matches the documented takeover pattern: attackers adopt orphaned
# packages and push malware under a new AUR account while forging the original
# maintainer's git author name (which is free text, NOT tied to the account
# that pushed).
#
# We therefore check the live AUR RPC `Maintainer` field (authenticated, tied to
# the SSH key) against a local snapshot — the RPC has no history endpoint and
# the git author name is forgeable.
#
# State: ~/.local/state/aur-maintainers  (pkg<TAB>maintainer, one per line)
#
# Usage:
#   aur-maintainer-check.sh            # check; exit 1 on suspicious change
#   aur-maintainer-check.sh --ack P    # accept P's current maintainer
#   aur-maintainer-check.sh --refresh  # re-baseline snapshot to current state

set -euo pipefail

STATE_FILE="${AUR_MAINTAINER_STATE:-$HOME/.local/state/aur-maintainers}"
RPC_URL='https://aur.archlinux.org/rpc/?v=5&type=info'

ack_pkg=""
refresh=0
while [ $# -gt 0 ]; do
    case "$1" in
        --ack)     ack_pkg="${2:?--ack needs a package name}"; shift 2 ;;
        --refresh) refresh=1; shift ;;
        -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

mkdir -p "$(dirname "$STATE_FILE")"

# Foreign (AUR) packages only — listed packages are never in the official repos.
foreign=$(pacman -Qqm)
if [ -z "$foreign" ]; then
    echo "No AUR packages installed."
    [ "$refresh" -eq 1 ] && : > "$STATE_FILE"
    exit 0
fi

# Bulk-query current maintainers (one request). jq fails loud on RPC error;
# orphaned packages have a null Maintainer, rendered as empty string.
curl_args=()
while IFS= read -r p; do
    curl_args+=( --data-urlencode "arg[]=$p" )
done <<< "$foreign"

declare -A cur
while IFS=$'\t' read -r pkg maint; do
    cur["$pkg"]="$maint"
done < <(curl -fsSL -G "$RPC_URL" "${curl_args[@]}" |
    jq -r 'if .error then error("RPC: "+.error)
           else .results[] | .Name + "\t" + (.Maintainer // "") end')

# --ack: accept one package's current maintainer, keep flagging the rest.
if [ -n "$ack_pkg" ]; then
    if [ -z "${cur[$ack_pkg]+x}" ]; then
        echo "ack: '$ack_pkg' is not an installed AUR package." >&2
        exit 1
    fi
    declare -A st
    [ -f "$STATE_FILE" ] && while IFS=$'\t' read -r k v; do st["$k"]="$v"; done < "$STATE_FILE"
    st["$ack_pkg"]="${cur[$ack_pkg]}"
    for k in "${!st[@]}"; do printf '%s\t%s\n' "$k" "${st[$k]}"; done | sort > "$STATE_FILE"
    echo "acked: $ack_pkg -> ${cur[$ack_pkg]:-<orphaned>}"
    exit 0
fi

# --refresh: accept all current maintainers and re-baseline.
if [ "$refresh" -eq 1 ]; then
    for k in "${!cur[@]}"; do printf '%s\t%s\n' "$k" "${cur[$k]}"; done | sort > "$STATE_FILE"
    echo "refreshed: ${#cur[@]} packages -> $STATE_FILE"
    exit 0
fi

# Load previous snapshot.
declare -A prev
[ -f "$STATE_FILE" ] && while IFS=$'\t' read -r k v; do prev["$k"]="$v"; done < "$STATE_FILE"

# Compare. Suspicious = a known package gained a *different* non-empty maintainer
# (orphan adopted, or hands changed). Becoming orphaned or first-seen is OK.
suspicious=0
for pkg in "${!cur[@]}"; do
    new="${cur[$pkg]}"
    [ -z "${prev[$pkg]+x}" ] && continue          # first-seen: seed silently
    old="${prev[$pkg]}"
    [ "$new" = "$old" ] && continue               # unchanged
    [ -z "$new" ] && continue                     # maintainer orphaned it: not an attack
    if [ -z "$old" ]; then
        printf 'SUSPICIOUS: %s: orphaned package adopted by %s\n' "$pkg" "$new" >&2
    else
        printf 'SUSPICIOUS: %s: maintainer changed %s -> %s\n' "$pkg" "$old" "$new" >&2
    fi
    suspicious=1
done

# Only persist when clean: a suspicious finding keeps flagging until resolved
# via --ack/--refresh, so a dismissed attack can't be silently re-baselined.
if [ "$suspicious" -eq 1 ]; then
    echo >&2
    echo "Update blocked: maintainer change matches the takeover pattern." >&2
    echo "  $0 --ack <pkg>       # accept the new maintainer (legit handoff)" >&2
    echo "  $0 --refresh         # accept all current maintainers" >&2
    echo "  yay -G --diff <pkg>  # inspect the PKGBUILD diff" >&2
    exit 1
fi

for k in "${!cur[@]}"; do printf '%s\t%s\n' "$k" "${cur[$k]}"; done | sort > "$STATE_FILE"
echo "OK: No suspicious maintainer changes."
