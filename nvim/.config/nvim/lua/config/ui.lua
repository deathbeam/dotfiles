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
require('bqf').setup({
    preview = {
        border = 'single',
    },
})

-- Toggle quickfix
nmap('<leader>q', function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        vim.cmd.cclose()
    else
        vim.cmd.copen()
    end
end)

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

-- Big files fast
au('BufReadPre', {
    pattern = '*',
    desc = 'Disable features on big files',
    callback = function(args)
        local bufnr = args.buf
        local size = vim.fn.getfsize(vim.fn.expand('%'))

        if size < 1024 * 1024 then
            return
        end

        vim.api.nvim_buf_set_var(bufnr, "bigfile_disable", 1)

        -- Disable treesitter
        require('nvim-treesitter.configs').get_module('indent').disable = function()
            return vim.api.nvim_buf_get_var(bufnr, "bigfile_disable") == 1
        end

        -- Disable autoindent
        vim.bo.indentexpr = ''
        vim.bo.autoindent = false
        vim.bo.smartindent = false
        -- Disable folding
        vim.opt_local.foldmethod = 'manual'
        vim.opt_local.foldexpr = '0'
        -- Disable statuscolumn
        vim.opt_local.statuscolumn = ''
        -- Disable search highlight
        vim.opt_local.hlsearch = false
        -- Disable line wrapping
        vim.opt_local.wrap = false
        -- Disable cursorline
        vim.opt_local.cursorline = false
        -- Disable swapfile
        vim.opt_local.swapfile = false
        -- Disable spell checking
        vim.opt_local.spell = false
    end,
})
