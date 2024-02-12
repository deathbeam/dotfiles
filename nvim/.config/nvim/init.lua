-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

require("mason").setup()
require("mason-tool-installer").setup {
    run_on_start = false,
    ensure_installed = vim.tbl_values(
        vim.tbl_flatten(
            vim.tbl_map(function(server) return server.mason end,
                vim.tbl_filter(function(server) return server.mason end,
                    require("config.languages")))))
}

require("config.rooter")
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
