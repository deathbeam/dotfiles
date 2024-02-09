-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

local utils = require("config.utils")
local nmap = utils.nmap

-- Quickfix mappings
nmap("<leader>q", "<cmd>copen<CR>", "Open [Q]uickfix")
nmap("]q", "<cmd>cnext<CR>", "Goto next [Q]uickfix entry")
nmap("[q", "<cmd>cprev<CR>", "Goto previous [Q]uickfix entry")

-- Mark mappings
nmap("dm", function() vim.api.nvim_buf_set_mark(0, vim.fn.nr2char(vim.fn.getchar()), 0, 0, {}) end, "Delete [M]ark")
nmap("dm<CR>", "<cmd>delm a-zA-Z0-9<CR>", "Delete [M]ark")

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
require("config.wiki")
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
