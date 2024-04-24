local utils = require('config.utils')
local au = utils.au

-- Set base16 colorscheme
vim.opt.termguicolors = true
local base16 = require('base16-colorscheme')
au('ColorScheme', {
    desc = 'Adjust colors',
    callback = function()
        local base0D = base16.colors.base0D
        local base00 = base16.colors.base00
        local base03 = base16.colors.base03

        vim.api.nvim_set_hl(0, 'StatusLine', { fg = base00, underline = false })
        vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = base03, underline = false })
        vim.api.nvim_set_hl(0, 'LineNr', { fg = base03 })
        vim.api.nvim_set_hl(0, 'VertSplit', { fg = base03 })
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = base03 })
        vim.api.nvim_set_hl(0, 'User1', { underline = false, bg = base0D, fg = base00 })
        vim.api.nvim_set_hl(0, 'User2', { underline = false, fg = base0D })
        vim.api.nvim_set_hl(0, 'User3', { underline = false, fg = base03 })
    end,
})
base16.load_from_shell()

-- Load icons
require('nvim-web-devicons').setup()

-- Load colors
require('nvim-highlight-colors').setup()

-- File browser
require('oil').setup({
    view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
            return name == '..'
        end,
    },
    keymaps = {
        ['<C-s>'] = false,
        ['<C-h>'] = false,
        ['<C-t>'] = false,
        ['<C-p>'] = false,
        ['<C-c>'] = false,
        ['<C-l>'] = false,
    },
})
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
au('FileType', {
    pattern = 'oil',
    desc = 'Set oil options',
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

-- Tmux bindings
require('tmux').setup({
    copy_sync = {
        enable = false,
    },
})
