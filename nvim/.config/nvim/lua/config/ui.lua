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
    end,
})
base16.load_from_shell()

-- Load icons
require('nvim-web-devicons').setup()

-- Which key, i guess
require('which-key').setup()

-- Better quickfix
require('bqf').setup({
    preview = {
        border = 'single',
    },
})

au('FileType', {
    pattern = 'qf',
    desc = 'Set quickfix options',
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

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

au('CursorMoved', {
    callback = function()
        -- No bloat lua adpatation of: https://github.com/romainl/vim-cool
        local view, rpos = vim.fn.winsaveview(), vim.fn.getpos('.')
        -- Move the cursor to a position where (whereas in active search) pressing `n`
        -- brings us to the original cursor position, in a forward search / that means
        -- one column before the match, in a backward search ? we move one col forward
        vim.cmd(
            string.format(
                'silent! keepjumps go%s',
                (vim.fn.line2byte(view.lnum) + view.col + 1 - (vim.v.searchforward == 1 and 2 or 0))
            )
        )
        -- Attempt to goto next match, if we're in an active search cursor position
        -- should be equal to original cursor position
        local ok, _ = pcall(vim.cmd, 'silent! keepjumps norm! n')
        local insearch = ok
            and (function()
                local npos = vim.fn.getpos('.')
                return npos[2] == rpos[2] and npos[3] == rpos[3]
            end)()
        -- restore original view and position
        vim.fn.winrestview(view)
        if not insearch then
            vim.schedule(function()
                vim.cmd('nohlsearch')
            end)
        end
    end,
})
