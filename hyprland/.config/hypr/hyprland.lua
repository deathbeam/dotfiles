-- Hyprland configuration (Lua, Hyprland >= 0.55).
-- Env vars live in bin/.local/bin/start-wm; $WALLPAPER/$SCALE_FACTOR come from zsh/.profile.

local SCALE_FACTOR = os.getenv("SCALE_FACTOR") or "1"
---------------
-- MONITORS --
---------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = SCALE_FACTOR,
    -- supports_wide_color = 1,
    -- supports_hdr        = 1,
})

---------------
-- XWAYLAND  --
---------------

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

----------------
-- LOOK/FEEL  --
----------------

hl.config({
    general = {
        gaps_in       = 0,
        gaps_out     = 0,
        border_size  = 1,

        col = {
            active_border   = "rgb(268bd2)",
            inactive_border = "rgb(657B83)",
        },

        resize_on_border = false,
        allow_tearing    = true,
        layout           = "master",

        snap = {
            enabled        = true,
            window_gap     = 1,
            monitor_gap    = 1,
            border_overlap = true,
            respect_gaps   = true,
        },
    },

    group = {
        col = {
            border_active   = "rgb(268bd2)",
            border_inactive = "rgb(657B83)",
        },

        groupbar = {
            font_family          = "monospace",
            font_size            = 16,
            font_weight_active   = "normal",
            font_weight_inactive = "normal",
            height               = 30,
            text_color           = 0xff93A1A1,
            text_color_inactive  = 0xff657B83,
            col = {
                active   = 0x66268bd2,
                inactive = 0x66657B83,
            },
            rounding         = 0,
            gaps_in          = 0,
            gaps_out         = 0,
            indicator_height = 5,
        },
    },

    dwindle = {
        preserve_split = true,
        force_split    = 2,
    },

    decoration = {
        dim_inactive = true,
        blur   = { enabled = false },
        shadow = { enabled = false },
    },

    animations = {
        enabled = false,
    },

    cursor = {
        no_hardware_cursors = true,
        inactive_timeout    = 5,
        enable_hyprcursor   = false,
        no_warps            = true,
    },

    misc = {
        vrr                        = 2,
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        disable_autoreload         = true,
        enable_anr_dialog          = false,
        middle_click_paste         = false,
        disable_watchdog_warning   = true,
    },

    input = {
        follow_mouse                = 0,
        float_switch_override_focus = 0,
    },

    ecosystem = {
        no_donation_nag = 1,
        no_update_news  = 1,
    },

    -- Cycle group windows first, then move to neighbours (replaces old H/L shell binds).
    binds = {
        movefocus_cycles_groupfirst = true,
    },
})

------------------
-- KEYBINDINGS  --
------------------

-- Applications
hl.bind("SUPER + Return",      hl.dsp.exec_cmd("terminal"),                                   { description = "terminal" })
hl.bind("SUPER + Tab",         hl.dsp.exec_cmd("menu-switch -p \"switch\""),                  { description = "switch" })
hl.bind("SUPER + space",       hl.dsp.exec_cmd("menu-run -p \"run\""),                        { description = "run" })
hl.bind("SUPER + p",           hl.dsp.exec_cmd("menu-pass -p \"pass\""),                      { description = "passwords" })
hl.bind("SUPER + x",           hl.dsp.exec_cmd("menu-proc -p \"proc\""),                      { description = "execute" })
hl.bind("SUPER + c",           hl.dsp.exec_cmd("menu-clip -p \"clip\""),                      { description = "copy" })
hl.bind("SUPER + g",           hl.dsp.exec_cmd("menu-steam -p \"steam\""),                    { description = "games" })
hl.bind("SUPER + i",           hl.dsp.exec_cmd("menu-yay -p \"yay\""),                        { description = "install" })
hl.bind("SUPER + n",           hl.dsp.exec_cmd("menu-notifications -p \"notifications\""),   { description = "notifications" })
hl.bind("SUPER + u",           hl.dsp.exec_cmd("menu-browser -p \"url\""),                    { description = "urls" })
hl.bind("SUPER + e",           hl.dsp.exec_cmd("swaylock -f -e -s fill -i $WALLPAPER"),         { description = "lock screen" })
hl.bind("SUPER + v",           hl.dsp.exec_cmd("pkill -USR1 gammastep"),                        { description = "flux" })
hl.bind("SUPER + slash",       hl.dsp.workspace.toggle_special("cheatsheet"),                   { description = "cheatsheet" })
hl.bind("SUPER + b",           hl.dsp.workspace.toggle_special("btop"),                         { description = "btop" })
hl.bind("SUPER + d",           hl.dsp.workspace.toggle_special("discord"),                      { description = "discord" })
hl.bind("SUPER + y",           hl.dsp.workspace.toggle_special("youtubemusic"),                  { description = "youtube" })
hl.bind("SUPER + o",           hl.dsp.workspace.toggle_special("kubernetes"),                   { description = "kubernetes" })
hl.bind("SUPER + SHIFT + o",   hl.dsp.workspace.toggle_special("docker"),                       { description = "docker" })

hl.bind("SUPER + a", hl.dsp.exec_cmd("menu-wifi -p \"wifi\""), { description = "wifi" })

-- PoE Leveling Overlay
hl.bind("SUPER + z",         hl.dsp.exec_cmd("~/.config/quickshell/poe-leveling/scripts/toggle.sh"), { description = "poe leveling toggle" })
hl.bind("SUPER + Left",      hl.dsp.exec_cmd("echo 'prev' | socat - UNIX-CONNECT:/tmp/poe-leveling.sock"), { description = "poe previous" })
hl.bind("SUPER + Right",     hl.dsp.exec_cmd("echo 'next' | socat - UNIX-CONNECT:/tmp/poe-leveling.sock"), { description = "poe next" })
hl.bind("SUPER + SHIFT + z", hl.dsp.exec_cmd("echo 'hints' | socat - UNIX-CONNECT:/tmp/poe-leveling.sock"), { description = "poe hints" })

----------------------
-- WORKSPACE RULES  --
----------------------

hl.workspace_rule({ workspace = "special:cheatsheet", on_created_empty = "overlay -t \"Cheatsheet\" glow -w 0 --pager ~/git/dotfiles/CHEATSHEET.md" })
hl.workspace_rule({ workspace = "special:btop",      on_created_empty = "overlay -t \"System\" btop" })
hl.workspace_rule({ workspace = "special:discord",    on_created_empty = "vesktop" })
hl.workspace_rule({ workspace = "special:youtubemusic", on_created_empty = "youtube-music" })
hl.workspace_rule({ workspace = "special:kubernetes", on_created_empty = "overlay -t \"Kubernetes\" k9s" })
hl.workspace_rule({ workspace = "special:docker",    on_created_empty = "overlay -t \"Docker\" lazydocker" })

--------------------
-- SPECIAL KEYS  --
--------------------

hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("swaylock -f -i $WALLPAPER"), { locked = true, description = "lock screen" })
-- hl.bind("Print", hl.dsp.exec_cmd("sleep 1 && grim -t ppm - | satty -f - -o \"$HOME/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png\""))
hl.bind("Print",            hl.dsp.exec_cmd("quickshell -c screenshot -n"), { description = "screenshot" })
hl.bind("SUPER + Print",    hl.dsp.exec_cmd("screenrecorder"), { description = "screen recorder" })
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("amixer -q set Master 5%+ on"), { description = "volume up" })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("amixer -q set Master 5%-"), { description = "volume down" })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("amixer -q set Master toggle"), { description = "mute" })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("privacy-toggle"), { description = "mic mute" })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("brightnessctl s +5%"), { description = "brightness up" })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("brightnessctl s 5%-"), { description = "brightness down" })
hl.bind("XF86KbdBrightnessUp",    hl.dsp.exec_cmd("asusctl -n"), { description = "keyboard brightness up" })
hl.bind("XF86KbdBrightnessDown",  hl.dsp.exec_cmd("asusctl -p"), { description = "keyboard brightness down" })
hl.bind("XF86Launch1",  hl.dsp.exec_cmd("rog-control-center"), { description = "rog control center" })
hl.bind("XF86Launch3",  hl.dsp.exec_cmd("asusctl led-mode -n"), { description = "led mode" })
hl.bind("XF86Launch4",  hl.dsp.exec_cmd("asusctl profile -p"), { description = "profile" })

------------------
-- MAIN BINDS  --
------------------

hl.bind("SUPER + SHIFT + escape", hl.dsp.exit(), { description = "exit" })
hl.bind("SUPER + escape",         hl.dsp.exec_cmd("hyprctl reload && notify-send \"Hyprland config reloaded\""), { description = "reload config" })
hl.bind("SUPER + W",              hl.dsp.window.close(), { description = "close window" })

-- Layout toggles
hl.bind("SUPER + S", hl.dsp.window.float({ action = "toggle" }), { description = "toggle float" })
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "maximize" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "fullscreen" })
hl.bind("SUPER + T", hl.dsp.group.toggle(), { description = "toggle group" })

-- Move focus
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "focus left" })
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }), { description = "focus right" })
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }), { description = "focus up" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }), { description = "focus down" })

-- Swap windows
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l", group_aware = true }), { description = "move left" })
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r", group_aware = true }), { description = "move right" })
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u", group_aware = true }), { description = "move up" })
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d", group_aware = true }), { description = "move down" })

-- Resize mode
hl.bind("SUPER + R", hl.dsp.submap("resize"), { description = "enter resize mode" })

hl.define_submap("resize", function()
    -- Resize windows
    hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true, description = "resize left" })
    hl.bind("L", hl.dsp.window.resize({ x = 20,  y = 0, relative = true }), { repeating = true, description = "resize right" })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true, description = "resize up" })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 20,  relative = true }), { repeating = true, description = "resize down" })

    -- Move windows
    hl.bind("SHIFT + H", hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true, description = "move left" })
    hl.bind("SHIFT + L", hl.dsp.window.move({ x = 20,  y = 0, relative = true }), { repeating = true, description = "move right" })
    hl.bind("SHIFT + K", hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true, description = "move up" })
    hl.bind("SHIFT + J", hl.dsp.window.move({ x = 0, y = 20,  relative = true }), { repeating = true, description = "move down" })

    hl.bind("escape",  hl.dsp.submap("reset"), { description = "exit resize mode" })
    hl.bind("Return", hl.dsp.submap("reset"), { description = "exit resize mode" })
end)

-- Switch workspaces
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }), { description = "workspace 1" })
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }), { description = "workspace 2" })
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }), { description = "workspace 3" })
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }), { description = "workspace 4" })
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }), { description = "workspace 5" })
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }), { description = "workspace 6" })
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }), { description = "workspace 7" })
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }), { description = "workspace 8" })
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }), { description = "workspace 9" })
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special(), { description = "toggle special workspace" })

-- Move active window to a workspace
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }), { description = "move to workspace 1" })
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }), { description = "move to workspace 2" })
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }), { description = "move to workspace 3" })
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }), { description = "move to workspace 4" })
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }), { description = "move to workspace 5" })
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }), { description = "move to workspace 6" })
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }), { description = "move to workspace 7" })
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }), { description = "move to workspace 8" })
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }), { description = "move to workspace 9" })
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special" }), { description = "move to special workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------
-- WINDOW RULES --
-------------------

hl.window_rule({
    name          = "suppress-maximize-fullscreen",
    match         = { class = ".*" },
    suppress_event = "maximize fullscreen",
})

-- Shell menu rules
hl.window_rule({
    name        = "shellmenu-float",
    match       = { class = "shellmenu" },
    float       = true,
})
hl.window_rule({ match = { class = "shellmenu" }, pin = true })
hl.window_rule({ match = { class = "shellmenu" }, border_size = 0 })
hl.window_rule({ match = { class = "shellmenu" }, move  = { "0", "monitor_h*0.5" } })
hl.window_rule({ match = { class = "shellmenu" }, size  = { "monitor_w", "monitor_h*0.5" } })
hl.window_rule({ match = { tag  = "shellmenu" }, focus_on_activate = true })
hl.window_rule({ match = { class = "shellmenu" }, stay_focused = true })

-- Overlay rules
hl.window_rule({ match = { class = "overlay" }, tag = "+overlay" })
hl.window_rule({ match = { tag = "overlay" }, border_size = 0 })
hl.window_rule({ match = { tag = "overlay" }, opacity = "0.8" })
hl.window_rule({ match = { tag = "overlay" }, focus_on_activate = true })
hl.window_rule({ match = { tag = "overlay" }, stay_focused = true })

-- Fullscreen overlay rules
hl.window_rule({ match = { class = "fsoverlay" }, tag = "+fsoverlay" })
hl.window_rule({ match = { tag = "fsoverlay" }, move  = { "0", "0" } })
hl.window_rule({ match = { tag = "fsoverlay" }, size  = { "monitor_w", "monitor_h" } })
hl.window_rule({ match = { tag = "fsoverlay" }, float = true })
hl.window_rule({ match = { tag = "fsoverlay" }, pin = true })
hl.window_rule({ match = { tag = "fsoverlay" }, border_size = 0 })
hl.window_rule({ match = { tag = "fsoverlay" }, focus_on_activate = true })
hl.window_rule({ match = { tag = "fsoverlay" }, stay_focused = true })

hl.window_rule({ match = { class = "com.gabm.satty" }, tag = "+fsoverlay" })

-- preview rules (menu-switch)
hl.window_rule({ match = { title = "^window_preview.*$" }, tag = "+preview" })
hl.window_rule({ match = { tag = "preview" }, float = true })
hl.window_rule({ match = { tag = "preview" }, pin = true })
hl.window_rule({ match = { tag = "preview" }, border_size = 0 })
hl.window_rule({ match = { tag = "preview" }, no_focus = true })
hl.window_rule({ match = { tag = "preview" }, move = { "(monitor_w*0.5)", "(monitor_h*0.52)" } })
hl.window_rule({ match = { tag = "preview" }, size = { "(monitor_w*0.5)", "(monitor_h*0.46)" } })

-- Game rules
hl.window_rule({ match = { content = "game" }, tag = "+game" })
hl.window_rule({ match = { class = "gamescope" }, tag = "+game" })
hl.window_rule({ match = { tag = "game" }, fullscreen = true })
hl.window_rule({ match = { tag = "game" }, render_unfocused = true })
-- hl.window_rule({ match = { tag = "game" }, stay_focused = true })

-- App rules
hl.window_rule({ match = { class = "^brave.*" },     workspace = "1" })
hl.window_rule({ match = { class = "^firefox.*" },   workspace = "1" })
hl.window_rule({ match = { class = "^qutebrowser.*" }, workspace = "1" })
hl.window_rule({ match = { class = "^chromium.*" },  workspace = "1" })

-------------
-- AUTOSTART --
-------------

hl.on("hyprland.start", function()
    hl.exec_cmd("keyd-application-mapper -d")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("swaybg -m fill -i $WALLPAPER")
    -- hl.exec_cmd("mpvpaper ALL output2.mp4 -p -o '--video-unscaled=yes --no-keepaspect --no-audio --loop --speed=0.5'")
    -- hl.exec_cmd("foot -a terminal-bg -o 'colors.alpha=0' sh -c 'sleep 1; cava'")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    hl.exec_cmd("gammastep -m wayland")
    hl.exec_cmd("dunst")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("jamesdsp -t")
    hl.exec_cmd("quickshell -c bar -n")
    hl.exec_cmd("foot --server")
end)
