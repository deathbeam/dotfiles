local icons = require('config.icons')
local utils = require('config.utils')
local desc = utils.desc
local nmap = utils.nmap

desc('<leader>p', 'Profiling', icons.ui.Perf)

-- Profiling
local profile = require('plenary.profile')
nmap('<leader>pp', function()
    ---@diagnostic disable-next-line: param-type-mismatch
    profile.start('profile.log', { flame = true })
end, 'Start profiling')
nmap('<leader>px', function()
    profile.stop()
end, 'Stop profiling')
