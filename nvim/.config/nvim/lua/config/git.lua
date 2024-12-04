local gitsigns = require('gitsigns')
local icons = require('config.icons')
local utils = require('config.utils')
local map = utils.map
local nmap = utils.nmap
local vmap = utils.vmap
local desc = utils.desc

desc('<leader>h', 'Hunk', icons.ui.Hunk)

gitsigns.setup({
    signcolumn = false,
    numhl = true,
    on_attach = function(bufnr)
        print('Gitsigns attached to buffer ' .. bufnr)
        nmap(']c', function()
            if vim.wo.diff then
                vim.cmd.normal({ ']c', bang = true })
            else
                gitsigns.nav_hunk('next')
            end
        end, 'Goto next hunk', bufnr)

        nmap('[c', function()
            if vim.wo.diff then
                vim.cmd.normal({ '[c', bang = true })
            else
                gitsigns.nav_hunk('prev')
            end
        end, 'Goto previous hunk', bufnr)

        -- Actions
        nmap('<leader>hs', gitsigns.stage_hunk, 'Stage hunk', bufnr)
        vmap('<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage hunk', bufnr)
        nmap('<leader>hr', gitsigns.reset_hunk, 'Reset hunk', bufnr)
        vmap('<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset hunk', bufnr)
        nmap('<leader>hS', gitsigns.stage_buffer, 'Stage buffer', bufnr)
        nmap('<leader>hu', gitsigns.undo_stage_hunk, 'Undo stage hunk', bufnr)
        nmap('<leader>hR', gitsigns.reset_buffer, 'Reset buffer', bufnr)
        nmap('<leader>hp', gitsigns.preview_hunk, 'Preview hunk', bufnr)
        nmap('<leader>hb', function()
            gitsigns.blame_line({ full = true })
        end, 'Blame line', bufnr)
        nmap('<leader>hB', gitsigns.blame, 'Blame', bufnr)
        nmap('<leader>hd', gitsigns.diffthis, 'Diff this', bufnr)
        nmap('<leader>hD', function()
            gitsigns.diffthis('~')
        end, 'Diff this (cached)', bufnr)

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk', bufnr)
    end,
})
