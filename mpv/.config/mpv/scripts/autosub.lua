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
-->>    OPTIONS:
--=============================================================================
-- Provider logins are read by subliminal directly from env vars, e.g.
-- SUBLIMINAL_PROVIDER_OPENSUBTITLESCOM_USERNAME / _PASSWORD (free account at
-- https://www.opensubtitles.com). opensubtitlescom requires login to download.
local debug = true  -- Enable debug logging and subliminal --debug output
--=============================================================================

local utils = require 'mp.utils'
local msg = require 'mp.msg'
local mp = mp

local function log(string, secs)
    secs = secs or 2.5
    msg.info(string)
    mp.osd_message(string, secs)
end

local function get_subtitle_path(directory, query, lang_code)
    -- subliminal names output <basename-without-ext>.<lang>.srt for file paths,
    -- and <query>.<lang>.srt for a bare title string.
    local name = query
    if query:find('^/') then
        local _, base = utils.splitPath(query)
        name = base
    end
    name = name:gsub('%.%w+$', '')
    return directory .. '/' .. name .. '.' .. lang_code .. '.srt'
end

local function file_exists(path)
    local file = io.open(path, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

local function clean_title(s)
    if not s or s == '' then return nil end
    -- Stremio hands mpv a URL; take the last path segment and URL-decode it
    if s:find('^https?://') then
        s = s:gsub('^https?://', '')
        s = s:gsub('[?#].*$', '')        -- drop query/fragment
        s = s:match('/(.+)$')             -- path after host; nil if none
        if not s then return nil end
        s = s:match('/([^/]+)/?$') or s   -- last path segment
        s = s:gsub('/+$', '')
        s = s:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    end
    s = s:gsub('%.%w+$', '')            -- strip a trailing extension if present
    s = s:gsub('[-._+]+', ' ')          -- separators -> spaces
    s = s:gsub('^%s+', ''):gsub('%s+$', '')
    return s ~= '' and s or nil
end

local function download_subs(directory, candidates)
    log('Searching ' .. language[1] .. ' subtitles ...', 30)

    for _, query in ipairs(candidates) do
        local args = { subliminal }

        if debug then
            table.insert(args, '--debug')
        end

        table.insert(args, 'download')
        table.insert(args, '-e')
        table.insert(args, 'utf-8')
        table.insert(args, '-l')
        table.insert(args, language[2])
        -- Require at least a title match: 50% of the movie hash score (323) = 161,
        -- which a title match (162) clears but a country-only non-match (54) never does.
        -- Without this gate, subliminal downloads a random wrong subtitle for obscure films.
        table.insert(args, '-m')
        table.insert(args, '50')
        -- omdb refiner ships with a dead apikey (401 every run); ignore the noise.
        table.insert(args, '-R')
        table.insert(args, 'omdb')
        table.insert(args, '-d')
        table.insert(args, directory)
        table.insert(args, query)

        if debug then
            msg.warn('Executing: ' .. table.concat(args, ' '))
        end

        local result = utils.subprocess({ args = args, cancellable = false })
        local sub_path = get_subtitle_path(directory, query, language[2])

        if debug then
            log('Checking for subtitle file at: ' .. sub_path)
        end

        if file_exists(sub_path) then
            mp.commandv('sub-add', sub_path, 'auto', language[1], language[2])
            log(language[1] .. ' subtitles ready!')
            return true
        end

        if debug then
            if result.stderr and result.stderr ~= '' then
                msg.warn('Subliminal error: ' .. result.stderr)
            end
            if result.stdout and result.stdout ~= '' then
                msg.warn('Subliminal output: ' .. result.stdout)
            end
        end

        log('No match for "' .. query .. '"')
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

    -- format may be nil for network streams (e.g. Stremio); only reject known non-video formats
    if not format then return true end

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

local function get_video_info()
    local path = mp.get_property('path')
    local title = mp.get_property('media-title') or ''
    local tmp_dir = os.getenv('TMPDIR') or os.getenv('TEMP') or os.getenv('TMP') or '/tmp'

    -- Local file: pass the real path so subliminal hash-matches (accurate, score 323).
    if path and path:find('^/') and file_exists(path) then
        return tmp_dir, { path }
    end

    -- Stream: subliminal can't hash a URL, so query by name. Try the media-title first
    -- (human-readable), then the URL path segment (often carries year/release info that
    -- helps guessit identify and score the video). Dedup.
    local candidates, seen = {}, {}
    for _, s in ipairs({ clean_title(title), clean_title(path) }) do
        if s and not seen[s] then
            seen[s] = true
            table.insert(candidates, s)
        end
    end

    if debug then
        msg.warn('autosub: candidates=' .. table.concat(candidates, ' | '))
    end

    if #candidates == 0 then return nil, nil end
    return tmp_dir, candidates
end

local function control_downloads()
    local video_dir, candidates = get_video_info()
    if not candidates then return end

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
        download_subs(video_dir, candidates)
    end
end

local function manual_download()
    local video_dir, candidates = get_video_info()
    if not candidates then return end
    download_subs(video_dir, candidates)
end

mp.add_key_binding('b', 'download_subs', manual_download)
mp.register_event('file-loaded', control_downloads)
