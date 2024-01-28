-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

require("tmux").setup {
    copy_sync = {
        enable = false
    }
}

require('nvim-web-devicons').setup()

require('eyeliner').setup {
    highlight_on_key = true,
    dim = true,
}

require("fidget").setup {
    notification = {
        override_vim_notify = not vim.tbl_isempty(vim.api.nvim_list_uis())
    },
    logger = {
        level = vim.log.levels.INFO
    }
}

local base16 = require('base16-colorscheme')
local function adjustColors()
    local base0A = base16.colors.base0A
    local base0D = base16.colors.base0D
    local base00 = base16.colors.base00
    local base03 = base16.colors.base03
    local base0B = base16.colors.base0B
    local base0E = base16.colors.base0E

    vim.api.nvim_set_hl(0, 'StatusLine', { fg = base00 })
    vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = base03 })
    vim.api.nvim_set_hl(0, 'VertSplit', { fg = base03 })
    vim.api.nvim_set_hl(0, 'User1', { underline = true, bg = base0D, fg = base00 })
    vim.api.nvim_set_hl(0, 'User2', { underline = true, fg = base0D })
    vim.api.nvim_set_hl(0, 'User3', { underline = true, fg = base0B })
    vim.api.nvim_set_hl(0, 'User4', { underline = true, fg = base0E })
    vim.api.nvim_set_hl(0, 'User5', { underline = true, fg = base0A })
end
vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Adjust colors',
    callback = adjustColors
})
base16.load_from_shell()

require("which-key").register {
    ['<leader>w'] = { name = "[W]iki", _ = 'which_key_ignore' },
}

require("finder")
require("treesitter")
require("completion")
require("lspdap")
require("languages/java")
require("languages/python")
