local icons = require('config.icons')
local utils = require('config.utils')
local nmap = utils.nmap
local desc = utils.desc

require('myplugins').setup({
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
    lspecho = {
        attach_log = true,
    },
    cmdcomplete = {},
    diagnostics = {},

    bigfile = {},
    rooter = {},
    difftool = {},
    session = {},
    zoom = {},
})

local bookmarks = require('myplugins.bookmarks')
desc('<leader>j', 'Bookmarks', icons.ui.Bookmark)
nmap('<leader>jj', bookmarks.toggle_file, 'Bookmarks Toggle File')
nmap('<leader>jl', bookmarks.toggle_line, 'Bookmarks Toggle Line')
nmap('<leader>jk', bookmarks.load, 'Bookmarks Clear')
nmap('<leader>jx', bookmarks.clear, 'Bookmarks Clear')
nmap(']j', function()
    bookmarks.load()
    vim.cmd('silent! cnext')
end, 'Bookmarks Next')
nmap('[j', function()
    bookmarks.load()
    vim.cmd('silent! cprevious')
end, 'Bookmarks Previous')

local wiki = require('myplugins.wiki')
desc('<leader>w', 'Wiki', icons.ui.Wiki)
nmap('<leader>wt', wiki.today, 'Wiki Today')
nmap('<leader>wd', wiki.list_diary, 'Wiki Diary List')
nmap('<leader>ww', wiki.list_wiki, 'Wiki List')
nmap('<leader>wn', wiki.new, 'Wiki New')

local undotree = require('myplugins.undotree')
nmap('<leader>fu', undotree.show, 'Find Undo History')

local zoom = require('myplugins.zoom')
nmap('<leader>z', zoom.toggle, 'Zoom')

local http = require('myplugins.httpyac')
desc('<leader>h', 'HTTP')
nmap('<leader>ho', http.toggle, 'HTTP Toggle')
nmap('<leader>hh', http.run, 'HTTP Run')
nmap('<leader>hH', http.run_all, 'HTTP Run All')
nmap('<leader>he', http.select_env, 'HTTP Environment')
