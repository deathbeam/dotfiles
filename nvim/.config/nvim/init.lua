-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

local utils = require('config.utils')
local au = utils.au

-- sync system clipboard and vim clipboard
au({ "FocusGained", "VimEnter" }, {
    callback = function()
        local content = vim.fn.getreg("+")
        if content and content ~= "" then
            vim.fn.setreg('"', content)
        end
    end,
})
au("TextYankPost", {
    callback = function()
        if vim.v.event.operator ~= "y" then
            return
        end
        local content = vim.fn.getreg('"')
        if content and content ~= "" then
            vim.fn.setreg("+", content)
        end
    end,
})

require('config.utils').nmap('<leader>m', function()
    local scratch_buffer = vim.api.nvim_create_buf(false, true)
    vim.bo[scratch_buffer].filetype = 'vim'
    local messages = vim.split(vim.fn.execute('messages', 'silent'), '\n')
    vim.api.nvim_buf_set_text(scratch_buffer, 0, 0, 0, 0, messages)
    vim.cmd('vertical sbuffer ' .. scratch_buffer)
end, 'Show messages')

require('config.registry')
require('mason').setup {
    ui = {
        border = "single",
    },
    registries = {
        "github:mason-org/mason-registry",
        "lua:config.registry",
    },
}

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
require('config.finder')
require('config.treesitter')
require('config.completion')
require('config.lsp')
require('config.dap')
require('config.copilot')
require('config.languages.java')
require('config.languages.javascript')
require('config.languages.python')
