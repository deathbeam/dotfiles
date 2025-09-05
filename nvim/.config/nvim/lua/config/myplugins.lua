local icons = require('config.icons')
local utils = require('config.utils')
local nmap = utils.nmap
local desc = utils.desc

require('myplugins').setup({
    -- bufcomplete = {
    --     entry_mapper = function(entry)
    --         local kind = entry.kind
    --         local icon = icons.kinds[kind]
    --         entry.kind = icon and icon .. ' ' .. kind or kind
    --         return entry
    --     end,
    -- },
    lspdocs = {},
    lspecho = {
        attach_log = true,
    },
    lspsignature = {},
    cmdcomplete = {},
    diagnostics = {},

    bigfile = {},
    rooter = {},
    -- difftool = {},
    session = {},
    zoom = {},
    wiki = {
        dir = vim.fn.expand('~/Wiki'),
    }
})

local bookmarks = require('myplugins.bookmarks')
desc('<leader>m', 'Bookmarks', icons.ui.Bookmark)
nmap('<leader>mm', bookmarks.select, 'Bookmarks Select')
nmap('<leader>mq', bookmarks.quickfix, 'Bookmarks Quickfix')
nmap('<leader>md', bookmarks.delete_buffer, 'Bookmarks Delete Buffer')
nmap('<leader>mD', bookmarks.delete_all, 'Bookmarks Delete All')
nmap("'", function()
    bookmarks.jump_to_mark(vim.fn.getcharstr())
end, 'Bookmarks Jump to Mark')
nmap('m', function()
    bookmarks.toggle_mark(vim.fn.getcharstr())
end, 'Bookmarks Toggle Mark')

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
