local icons = require('config.icons')
local utils = require('config.utils')
local nmap = utils.nmap
local desc = utils.desc

require('myplugins').setup {
    signature = {
        border = 'single',
    },
    bufcomplete = {
        border = 'single',
        entry_mapper = function(entry)
            local kind = entry.kind
            local icon = icons.kinds[kind]
            entry.kind = icon and icon .. ' ' .. kind or kind
            return entry
        end,
    },
    cmdcomplete = {},
    diagnostics = {},

    bigfile = {},
    rooter = {},
    difftool = {},
    -- session = {},
}

desc('<leader>w', 'Wiki', icons.ui.Wiki)
local wiki = require('myplugins.wiki')
nmap('<leader>wt', wiki.today, 'Wiki Today')
nmap('<leader>wd', wiki.list_diary, 'Wiki Diary List')
nmap('<leader>ww', wiki.list_wiki, 'Wiki List')
nmap('<leader>wn', wiki.new, 'Wiki New')

nmap('<leader>fu', require('myplugins.undotree').show, 'Find Undo History')
