local gitsigns = require('gitsigns')
local icons = require('config.icons')
local utils = require('config.utils')
local map = utils.map
local nmap = utils.nmap
local vmap = utils.vmap
local desc = utils.desc

desc('<leader>g', 'Git', icons.ui.Hunk)

gitsigns.setup({
    signcolumn = false,
    numhl = true,
    on_attach = function(bufnr)
        nmap(']g', function()
            if vim.wo.diff then
                vim.cmd.normal({ ']c', bang = true })
            else
                gitsigns.nav_hunk('next')
            end
        end, 'Goto next hunk', bufnr)

        nmap('[g', function()
            if vim.wo.diff then
                vim.cmd.normal({ '[c', bang = true })
            else
                gitsigns.nav_hunk('prev')
            end
        end, 'Goto previous hunk', bufnr)

        -- Actions
        nmap('<leader>gs', gitsigns.stage_hunk, 'Stage hunk', bufnr)
        vmap('<leader>gs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage hunk', bufnr)
        nmap('<leader>gS', gitsigns.stage_buffer, 'Stage buffer', bufnr)
        nmap('<leader>gr', gitsigns.reset_hunk, 'Reset hunk', bufnr)
        vmap('<leader>gr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset hunk', bufnr)
        nmap('<leader>gR', gitsigns.reset_buffer, 'Reset buffer', bufnr)
        nmap('<leader>gp', gitsigns.preview_hunk, 'Preview hunk', bufnr)
        nmap('<leader>gb', function()
            gitsigns.blame_line({ full = true })
        end, 'Blame line', bufnr)
        nmap('<leader>gB', gitsigns.blame, 'Blame', bufnr)
        nmap('<leader>gd', gitsigns.diffthis, 'Diff this', bufnr)
        nmap('<leader>gD', function()
            gitsigns.diffthis('~')
        end, 'Diff this (cached)', bufnr)

        -- Text object
        map({ 'o', 'x' }, 'ig', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk', bufnr)
    end,
})
