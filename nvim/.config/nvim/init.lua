-- Enable experimental loader
vim.loader.enable()

-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

local luarocks_path = {
    vim.fs.joinpath('/usr', 'share', 'lua', '5.1', '?.lua'),
    vim.fs.joinpath('/usr', 'share', 'lua', '5.1', '?', 'init.lua'),
}

local luarocks_cpath = {
    vim.fs.joinpath('/usr', 'lib', 'lua', '5.1', '?.so'),
    vim.fs.joinpath('/usr', 'lib64', 'lua', '5.1', '?.so'),
}

package.path = package.path .. ';' .. table.concat(luarocks_path, ';')
package.cpath = package.cpath .. ';' .. table.concat(luarocks_cpath, ';')

require('mason').setup()
require('mason-tool-installer').setup({
    run_on_start = false,
    ensure_installed = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(
        function(server)
            return server.mason
        end,
        vim.tbl_filter(function(server)
            return server.mason
        end, require('config.languages'))
    ))),
})

require('config.rooter')
require('config.ui')
require('config.wiki')
require('config.statuscolumn')
require('config.statusline')
require('config.finder')
require('config.treesitter')
require('config.completion')
require('config.copilot')
require('config.lsp')
require('config.dap')
require('config.languages.java')
require('config.languages.javascript')
require('config.languages.python')
