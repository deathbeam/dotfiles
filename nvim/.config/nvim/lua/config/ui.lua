local utils = require('config.utils')
local au = utils.au
local nmap = utils.nmap
local icons = require('config.icons')

-- Set win border
vim.o.winborder = 'single'

-- Enable help stuff
vim.g.helpful = 1

-- Ext ui native
require('vim._extui').enable({
    msg = {
        target = 'cmd',
        timeout = 1000,
    }
})

-- Set base16 colorscheme
local base16 = require('base16-colorscheme')
vim.opt.termguicolors = true
au('ColorScheme', {
    desc = 'Adjust colors',
    callback = function()
        local bright_black = base16.colors.base03
        vim.api.nvim_set_hl(0, 'StatusLine', { fg = bright_black })
        vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = bright_black })
        vim.api.nvim_set_hl(0, 'LineNr', { fg = bright_black })
        vim.api.nvim_set_hl(0, 'VertSplit', { fg = bright_black })
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = bright_black })

        local function blend_color(color_name, blend)
            local color_int = vim.api.nvim_get_hl(0, { name = color_name }).fg
            local bg_int = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg

            if not color_int or not bg_int then
                return
            end

            local color = { (color_int / 65536) % 256, (color_int / 256) % 256, color_int % 256 }
            local bg = { (bg_int / 65536) % 256, (bg_int / 256) % 256, bg_int % 256 }
            local r = math.floor((color[1] * blend + bg[1] * (100 - blend)) / 100)
            local g = math.floor((color[2] * blend + bg[2] * (100 - blend)) / 100)
            local b = math.floor((color[3] * blend + bg[3] * (100 - blend)) / 100)
            vim.api.nvim_set_hl(0, color_name, { bg = string.format('#%02x%02x%02x', r, g, b) })
        end

        blend_color('DiffAdd', 20)
        blend_color('DiffDelete', 20)
        blend_color('DiffChange', 20)
        blend_color('DiffText', 20)
    end,
})
vim.cmd('colorscheme base16-' .. os.getenv('BASE16_THEME_DEFAULT'))

-- Load icons
require('nvim-web-devicons').setup()

-- Set fold icons
vim.opt.fillchars = { foldclose = icons.fold.Closed, foldopen = icons.fold.Open }

-- File browser
local oil = require('oil')
oil.setup({
    view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
            return name == '..'
        end,
    },
    win_options = {
        number = false,
        relativenumber = false,
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

au('User', {
    pattern = 'OilEnter',
    callback = function()
        oil.open_preview()
    end,
})

nmap('-', oil.open, 'Open parent directory')
-- require('mini.files').setup()
-- nmap('-', require('mini.files').open, 'Open parent directory')

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
