#!/bin/sh

# socat -U - UNIX-CONNECT:/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock | while read -r line; do
socat -U - UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock | while read -r line; do
    window=$(hyprctl activewindow -j)
    workspace=$(hyprctl activeworkspace -j)
    workspaces=$(hyprctl workspaces -j)
    monitor=$(echo "${workspace}" | jq -r '.monitor')
    title=
    process=
    layout=
    if [ "$window" != "{}" ]; then
        title=$(echo "${window}" | jq -r '.title')
        process=$(echo "${window}" | jq -r '.class')
        floating=$(echo "${window}" | jq -r '.floating')
        if [ "$floating" = "true" ]; then
            layout="${layout}S"
        else
            layout="${layout}─"
        fi
        fullscreen=$(echo "${window}" | jq -r '.fullscreen')
        if [ "$fullscreen" = "true" ]; then
            layout="${layout}F"
        else
            layout="${layout}─"
        fi
    fi
    if [ -z "$layout" ]; then
        layout="──"
    fi

    for i in $(seq 1 5); do
        workspace_status="empty"
        if echo "${workspaces}" | jq -e --argjson num $i '.[] | select(.id == $num)' > /dev/null; then
            workspace_status="occupied"
        fi
        if [ $i -eq $(echo "${workspace}" | jq -r '.id') ]; then
            workspace_status="focused"
        fi
        echo "ws${i}_state|string|${workspace_status}"
    done

    echo "monitor|string|${monitor}"
    echo "layout|string|${layout}"
    echo "process|string|${process}"
    echo "title|string|${title}"
    echo ""
done
