#!/bin/sh

urgent_workspace=

# socat -U - UNIX-CONNECT:/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock | while read -r line; do
socat -U - UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock | while read -r line; do
    window=$(hyprctl activewindow -j)

    if [[ "$line" == urgent* ]]; then
        urgent_window="0x$(echo "$line" | awk -F'>>' '{print $2}')"
        window_address=$(echo "${window}" | jq -r '.address')

        if [ "$window_address" != "$urgent_window" ]; then
            windows=$(hyprctl clients -j)
            urgent_workspace=$(echo "${windows}" | jq -r --arg address "$urgent_window" '.[] | select(.address == $address) | .workspace.id')
        fi
    elif [[ "$line" == workspacev2* ]]; then
        workspace_id=$(echo "$line" | awk -F'>>' '{split($2,a,","); print a[1]}')
        if [ "$workspace_id" = "$urgent_workspace" ]; then
            urgent_workspace=
        fi
    fi

    workspace=$(hyprctl activeworkspace -j)
    workspaces=$(hyprctl workspaces -j)
    monitor=$(echo "${workspace}" | jq -r '.monitor')
    xwayland=$(echo "${window}" | jq -r '.xwayland')
    monocle=false
    floating=false
    fullscreen=false
    title=
    process=

    if [ "$window" != "{}" ]; then
        title=$(echo "${window}" | jq -r '.title')
        process=$(echo "${window}" | jq -r '.class' | rev | cut -d '.' -f 1 | rev)
        floating=$(echo "${window}" | jq -r '.floating')
        fullscreen=$(echo "${window}" | jq -r '.fullscreen')
        fullscreenMode=$(echo "${window}" | jq -r '.fullscreenMode')
        if [ "$fullscreen" = "true" ] && [ "$fullscreenMode" = "1" ]; then
            monocle=true
            fullscreen=false
        fi
    fi

    for i in $(seq 1 5); do
        workspace_status="empty"
        if [ "$i" = "$urgent_workspace" ]; then
            workspace_status="urgent"
        elif [ $i -eq $(echo "${workspace}" | jq -r '.id') ]; then
            workspace_status="focused"
        elif echo "${workspaces}" | jq -e --argjson num $i '.[] | select(.id == $num)' > /dev/null; then
            workspace_status="occupied"
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
