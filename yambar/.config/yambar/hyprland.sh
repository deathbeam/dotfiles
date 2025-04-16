#!/bin/sh

urgent_workspace_id=-1

# Wrapper function to handle the main loop
handle_events() {
    socat -U - "UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do
        # Check if Hyprland is still running
        if ! pgrep -x Hyprland >/dev/null; then
            return 1
        fi

        # Read active window data
        window_info=()
        if ! read_window_info=$(hyprctl activewindow -j 2>/dev/null); then
            continue
        fi

        while IFS= read -r l
        do
            window_info+=("$l")
        done < <(echo "$read_window_info" | jq -r '.address // "", .title // "", .class // "", .xwayland // false, .floating // false, .fullscreen // 0, .fullscreenClient // 0')

        window_address=${window_info[0]}
        title=${window_info[1]}
        process=${window_info[2]}
        process=$(echo "$process" | awk -F'.' '{print $NF}')
        xwayland=${window_info[3]}
        floating=${window_info[4]}
        monocle=$([ ${window_info[6]} -eq 1 ] && echo "true" || echo "false")
        fullscreen=$([ "$monocle" = true ] && echo "false" || ([ "${window_info[5]}" = "2" ] && echo "true" || echo "false"))

        # Read active workspace data
        workspace_info=()
        if ! read_workspace_info=$(hyprctl activeworkspace -j 2>/dev/null); then
            continue
        fi

        while IFS= read -r l
        do
            workspace_info+=("$l")
        done < <(echo "$read_workspace_info" | jq -r '.id // -1, .monitor // ""')
        workspace_id=${workspace_info[0]}
        monitor=${workspace_info[1]}

        # Check if the workspace exists
        workspace_exists=()
        if ! read_workspaces=$(hyprctl workspaces -j 2>/dev/null); then
            continue
        fi

        for workspace in $(echo "$read_workspaces" | jq -r '.[].id'); do
            workspace_exists[$workspace]=1
        done

        # If we received urgent window event mark urgent workspace
        if [[ "$line" == urgent* ]]; then
            urgent_window_address="0x$(echo "$line" | awk -F'>>' '{print $2}')"
            if [ "$window_address" != "$urgent_window_address" ]; then
                if ! read_clients=$(hyprctl clients -j 2>/dev/null); then
                    continue
                fi
                urgent_workspace_id=$(echo "$read_clients" | jq -r --arg address "$urgent_window_address" '.[] | select(.address == $address) | .workspace.id')
            fi
        fi

        # If we are already on urgent workspace unset it
        if [ "$workspace_id" = "$urgent_workspace_id" ]; then
            urgent_workspace_id=-1
        fi

        # Mark workspaces as either empty, urgent, focused or occupied
        for i in $(seq 1 9); do
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

        echo "mode|string|$(hyprctl submap | tr '[:lower:]' '[:upper:]')"
        echo "monitor|string|${monitor}"
        echo "monocle|bool|${monocle}"
        echo "floating|bool|${floating}"
        echo "fullscreen|bool|${fullscreen}"
        echo "xwayland|bool|${xwayland}"
        echo "process|string|${process}"
        echo "title|string|${title}"
        echo ""
    done
}

while true; do
    # Run the main handler and restart if it fails
    handle_events
    sleep 1
done
