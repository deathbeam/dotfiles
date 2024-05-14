#!/bin/sh

urgent_workspace_id=-1
was_fullscreen=false

tmp_sock="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
runtime_sock="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

if [ -S "$tmp_sock" ]; then
    sock="$tmp_sock"
elif [ -S "$runtime_sock" ]; then
    sock="$runtime_sock"
else
    echo "error|socket not found"
    exit 1
fi

socat -U - "UNIX-CONNECT:$sock" | while read -r line; do
    # Read active winow data
    window_info=()
    while IFS= read -r l
    do
        window_info+=("$l")
    done < <(hyprctl activewindow -j | jq -r '.address // "", .title // "", .class // "", .xwayland // false, .floating // false, .fullscreen // false, .fullscreenMode // 0')
    window_address=${window_info[0]}
    title=${window_info[1]}
    process=${window_info[2]}
    process=$(echo "$process" | awk -F'.' '{print $NF}')
    xwayland=${window_info[3]}
    floating=${window_info[4]}
    monocle=$([ ${window_info[6]} -eq 1 ] && echo "true" || echo "false")
    fullscreen=$([ "$monocle" = true ] && echo "false" || echo "${window_info[5]}")

    # Toggle gammastep on fullscreen change (only for xwayland windows, so steam)
    if [ "$fullscreen" = true ] && [ "$xwayland" = true ] && [ "$was_fullscreen" = false ]; then
        was_fullscreen=true
        pkill -USR1 gammastep
    elif [ "$fullscreen" = false ] && [ "$was_fullscreen" = true ]; then
        was_fullscreen=false
        pkill -USR1 gammastep
    fi

    # Read active workspace data
    workspace_info=()
    while IFS= read -r l
    do
        workspace_info+=("$l")
    done < <(hyprctl activeworkspace -j | jq -r '.id // -1, .monitor // ""')
    workspace_id=${workspace_info[0]}
    monitor=${workspace_info[1]}

    # Check if the workspace exists
    workspace_exists=()
    for workspace in $(hyprctl workspaces -j | jq -r '.[].id'); do
        workspace_exists[$workspace]=1
    done

    # If we received urgent window event mark urgent workspace
    if [[ "$line" == urgent* ]]; then
        urgent_window_address="0x$(echo "$line" | awk -F'>>' '{print $2}')"
        if [ "$window_address" != "$urgent_window_address" ]; then
            urgent_workspace_id=$(hyprctl clients -j | jq -r --arg address "$urgent_window_address" '.[] | select(.address == $address) | .workspace.id')
        fi
    fi

    # If we are already on urgent workspace unset it
    if [ "$workspace_id" = "$urgent_workspace_id" ]; then
        urgent_workspace_id=-1
    fi

    # Mark workspaces as either empty, urgent, focused or occupied
    for i in $(seq 1 5); do
        if [ $i -eq $urgent_workspace_id ]; then
            workspace_status="urgent"
        elif [ $i -eq $workspace_id ]; then
            workspace_status="focused"
        elif [ ${workspace_exists[$i]} ]; then
            workspace_status="occupied"
        else
            workspace_status="empty"
        fi
        echo "ws${i}_state|string|${workspace_status}"
    done

    echo "monitor|string|${monitor}"
    echo "monocle|bool|${monocle}"
    echo "floating|bool|${floating}"
    echo "fullscreen|bool|${fullscreen}"
    echo "xwayland|bool|${xwayland}"
    echo "process|string|${process}"
    echo "title|string|${title}"
    echo ""
done
