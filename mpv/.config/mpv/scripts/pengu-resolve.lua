-- pengu.uk (penguplay addon) streams break in two layers:
--  1. pengu.uk itself is Cloudflare-fronted and 428-blocks ffmpeg's TLS fingerprint,
--     so mpv can't even follow the redirect. curl passes -> resolve it here.
--  2. The CDN behind the redirect (hcdnN.hakunaymatata.com) 428-blocks browser-like
--     User-Agents, and mpv.conf sets "User-Agent: Mozilla/5.0" for Stremio streams.
--     A plain UA (curl/Lavf) passes -> override per-file.
local utils = require 'mp.utils'

local configured_headers = mp.get_property('http-header-fields') or ''

mp.add_hook('on_load', 50, function()
    local path = mp.get_property('stream-open-filename')
    if not path or not path:find('^https?://[^/]*pengu%.uk/') then
        mp.set_property('http-header-fields', configured_headers)
        return
    end

    local r = utils.subprocess({
        args = { 'curl', '-sL', '-m', '15', '-o', '/dev/null',
                 '-w', '%{url_effective}', '-r', '0-0', path },
        cancellable = false,
    })
    local final = r.status == 0 and r.stdout and r.stdout:gsub('%s+$', '') or ''

    if final ~= '' and final ~= path then
        mp.set_property('stream-open-filename', final)
    end
    mp.set_property('http-header-fields', 'User-Agent: curl/8.16.0')
    mp.osd_message('Resolved pengu redirect: ' .. (final:match('^https?://([^/]+)') or final))
end)
