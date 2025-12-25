--=============================================================================
-->>    SUBLIMINAL PATH:
--=============================================================================
local subliminal = 'subliminal'

--=============================================================================
-->>    SUBTITLE LANGUAGE:
--=============================================================================
--          { 'language name', 'ISO-639-1', 'ISO-639-2' }
local language = { 'English', 'en', 'eng' }

--=============================================================================
-->>    PROVIDER LOGINS:
--=============================================================================
local providers = {
    { name = "addic7ed", env = "ADDIC7ED" },
    { name = "gestdown", env = "GESTDOWN" },
    { name = "napiprojekt", env = "NAPIPROJEKT" },
    { name = "opensubtitles", env = "OPENSUBTITLES" },
    { name = "opensubtitlescom", env = "OPENSUBTITLESCOM" },
    { name = "opensubtitlescomvip", env = "OPENSUBTITLESCOMVIP" },
    { name = "opensubtitlesvip", env = "OPENSUBTITLESVIP" },
    { name = "podnapisi", env = "PODNAPISI" },
    { name = "subtitulamos", env = "SUBTITULAMOS" },
    { name = "tvsubtitles", env = "TVSUBTITLES" },
    { name = "subscenter", env = "SUBSCENTER" },
}

--=============================================================================
-->>    OPTIONS:
--=============================================================================
local debug = false  -- Enable debug logging and subliminal --debug output
--=============================================================================

local utils = require 'mp.utils'
local msg = require 'mp.msg'
local mp = mp

local function log(string, secs)
    secs = secs or 2.5
    msg.info(string)
    mp.osd_message(string, secs)
end

local function get_subtitle_path(directory, filename, lang_code)
    local base_name = filename:gsub('%..-$', '')
    return directory .. '/' .. base_name .. '.' .. lang_code .. '.srt'
end

local function file_exists(path)
    local file = io.open(path, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

local function download_subs(directory, filename)
    log('Searching ' .. language[1] .. ' subtitles ...', 30)

    local logins = {}
    for _, p in ipairs(providers) do
        local user = os.getenv(p.env .. "_USERNAME")
        local pass = os.getenv(p.env .. "_PASSWORD")
        if user and pass then
            table.insert(logins, { "--" .. p.name, user, pass })
        end
    end

    local args = { subliminal }

    for _, login in ipairs(logins) do
        table.insert(args, login[1])
        table.insert(args, login[2])
        table.insert(args, login[3])
    end

    if debug then
        table.insert(args, '--debug')
    end

    table.insert(args, 'download')
    table.insert(args, '-e')
    table.insert(args, 'utf-8')
    table.insert(args, '-l')
    table.insert(args, language[2])
    table.insert(args, '-d')
    table.insert(args, directory)
    table.insert(args, filename)

    if debug then
        msg.warn('Executing: ' .. table.concat(args, ' '))
    end

    local result = utils.subprocess({ args = args, cancellable = false })

    if result.status == 0 then
        local sub_path = get_subtitle_path(directory, filename, language[2])

        if file_exists(sub_path) then
            mp.commandv('sub-add', sub_path, 'auto', language[1])
            log(language[1] .. ' subtitles ready!')
            return true
        end
    end

    if debug then
        if result.stderr and result.stderr ~= '' then
            msg.warn('Subliminal error: ' .. result.stderr)
        end
        if result.stdout and result.stdout ~= '' then
            msg.warn('Subliminal output: ' .. result.stdout)
        end
    end

    log('No ' .. language[1] .. ' subtitles found')
    return false
end

local function should_download_subs(sub_tracks)
    for i, track in ipairs(sub_tracks) do
        local is_external = track.external or false
        local subtitles = is_external and 'subtitle file' or 'embedded subtitles'

        if track.lang == language[2] or track.lang == language[3] or
           (track.title and track.title:lower():find(language[3]:lower())) then
            if not track.selected then
                mp.set_property('sid', track.id)
                log('Enabled ' .. language[1] .. ' ' .. subtitles)
            else
                log(language[1] .. ' ' .. subtitles .. ' already active')
            end
            return false
        end

        if i == #sub_tracks and not track.lang and (is_external or not track.title) then
            log('Unknown ' .. subtitles .. ' present')
            return false
        end
    end

    if debug then
        msg.warn('No ' .. language[1] .. ' subtitles detected, downloading...')
    end
    return true
end

local function is_valid_video(duration, format)
    if not duration or duration < 900 then
        if debug then
            msg.warn('Video too short (<15min), skipping auto-download')
        end
        return false
    end

    if not format then return false end

    if format:find('^cue') then
        if debug then
            msg.warn('CUE file detected, skipping auto-download')
        end
        return false
    end

    local audio_formats = {'aiff', 'ape', 'flac', 'mp3', 'ogg', 'wav', 'wv', 'tta'}
    for _, fmt in ipairs(audio_formats) do
        if format == fmt then
            if debug then
                msg.warn('Audio file detected, skipping auto-download')
            end
            return false
        end
    end

    return true
end

local function get_path_and_file()
    local path = mp.get_property('path')
    if not path then
        return nil, nil
    end

    local _, video_file = utils.split_path(path)
    local tmp_dir = os.getenv('TMPDIR') or os.getenv('TEMP') or os.getenv('TMP') or '/tmp'
    return tmp_dir, video_file
end

local function control_downloads()
    local video_dir, video_file = get_path_and_file()
    if not video_file then return end

    local duration = tonumber(mp.get_property('duration'))
    local format = mp.get_property('file-format')

    if not is_valid_video(duration, format) then
        return
    end

    mp.set_property('sub-auto', 'fuzzy')
    mp.set_property('slang', language[2])
    mp.commandv('rescan_external_files')

    local sub_tracks = {}
    local track_list = mp.get_property_native('track-list')
    if track_list then
        for _, track in ipairs(track_list) do
            if track.type == 'sub' then
                table.insert(sub_tracks, track)
            end
        end
    end

    if debug then
        for _, track in ipairs(sub_tracks) do
            msg.warn('Subtitle track ' .. track.id .. ':')
            for k, v in pairs(track) do
                msg.warn('  ' .. k .. ': ' .. tostring(v))
            end
        end
    end

    if should_download_subs(sub_tracks) then
        download_subs(video_dir, video_file)
    end
end

local function manual_download()
    local video_dir, video_file = get_path_and_file()
    if not video_file then return end
    download_subs(video_dir, video_file)
end

mp.add_key_binding('b', 'download_subs', manual_download)
mp.register_event('file-loaded', control_downloads)
