-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

local utils = require("config.utils")

utils.desc("<leader>w", "[W]iki")

utils.nmap("<leader>q", "<cmd>copen<CR>", "Open [Q]uickfix")
utils.nmap("]q", "<cmd>cnext<CR>", "Goto next [Q]uickfix entry")
utils.nmap("[q", "<cmd>cprev<CR>", "Goto previous [Q]uickfix entry")

vim.g.rooter_patterns = {
    '.git',
    '.git/',
    '_darcs/',
    '.hg/',
    '.bzr/',
    '.svn/',
    '.editorconfig',
    'Makefile',
    '.pylintrc',
    'requirements.txt',
    'setup.py',
    'package.json',
    'mvnw',
    'gradlew',
}

vim.g.vimwiki_list = {{
    path = '~/vimwiki/',
    syntax =  'markdown',
    ext = '.md'
}}

vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_table_mappings = 0

utils.au("BufEnter", {
    pattern = "diary.md",
    command = "VimwikiDiaryGenerateLinks"
})

require("mason").setup()
require("mason-tool-installer").setup {
    run_on_start = false,
    ensure_installed = vim.tbl_values(
        vim.tbl_flatten(
            vim.tbl_map(function(server) return server.mason end,
                vim.tbl_filter(function(server) return server.mason end,
                    require("config.languages")))))
}

require("config.ui")
require("config.statuscolumn")
require("config.statusline")
require("config.finder")
require("config.treesitter")
require("config.completion")
require("config.lsp")
require("config.dap")
require("config.languages.java")
require("config.languages.javascript")
require("config.languages.python")
