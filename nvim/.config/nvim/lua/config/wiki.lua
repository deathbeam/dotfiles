local utils = require('config.utils')
local desc = utils.desc
local au = utils.au

desc('<leader>w', 'Wiki')

vim.g.vimwiki_list = { {
    path = '~/vimwiki/',
    syntax = 'markdown',
    ext = '.md',
} }

vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_table_mappings = 0

au('BufEnter', {
    pattern = 'diary.md',
    command = 'VimwikiDiaryGenerateLinks',
})
