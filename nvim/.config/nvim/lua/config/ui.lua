local utils = require('config.utils')
local au = utils.au
local nmap = utils.nmap

-- Set base16 colorscheme
local base16 = require('base16-colorscheme')
vim.opt.termguicolors = true
au('ColorScheme', {
    desc = 'Adjust colors',
    callback = function()
        local base03 = base16.colors.base03
        vim.api.nvim_set_hl(0, 'StatusLine', { fg = base03 })
        vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = base03 })
        vim.api.nvim_set_hl(0, 'LineNr', { fg = base03 })
        vim.api.nvim_set_hl(0, 'VertSplit', { fg = base03 })
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = base03 })
        -- vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', {})
    end,
})
base16.load_from_shell()

-- Load icons
require('nvim-web-devicons').setup()

-- Toggle zen mode
local zen_mode = require('zen-mode')

nmap('<leader>z', function()
    zen_mode.toggle({
        window = {
            width = 0.85,
        },
        plugins = {
            alacritty = {
                enabled = true,
            },
        },
    })
end)

-- Better quickfix
local quicker = require('quicker')
quicker.setup({
    follow = {
        enabled = true,
    },
    keys = {
        {
            '>',
            quicker.expand,
            desc = 'Expand quickfix context',
        },
        {
            '<',
            quicker.collapse,
            desc = 'Collapse quickfix context',
        },
    },
})

-- Toggle quickfix
nmap('<leader>q', quicker.toggle)

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

nmap('-', '<CMD>Oil<CR>', 'Open parent directory')

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

-- Remove HL after im done searching
au('InsertEnter', {
    callback = function()
        vim.schedule(function()
            vim.cmd('nohlsearch')
        end)
    end,
})

-- Profiling
local profile = require('plenary.profile')
nmap('<leader>pp', function()
    ---@diagnostic disable-next-line: param-type-mismatch
    profile.start("profile.log", { flame = true })
end, 'Start profiling')
nmap('<leader>px', function()
    profile.stop()
end, 'Stop profiling')
