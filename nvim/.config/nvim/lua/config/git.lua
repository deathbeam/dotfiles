local gitsigns = require('gitsigns')
local diffview = require('diffview')
local fzf = require('fzf-lua')
local diffviewlib = require('diffview.lib')
local icons = require('config.icons')
local utils = require('config.utils')
local map = utils.map
local nmap = utils.nmap
local nvmap = utils.nvmap
local vmap = utils.vmap
local desc = utils.desc

desc('<leader>g', 'Git', icons.ui.Git)

-- Diff view
local function diff_view(input)
    local view = diffviewlib.get_current_view()
    if view then
        diffview.close()
    else
        diffview.open({ args = { input } })
    end
end

nmap('<leader>go', function()
    diff_view()
end, 'Diff view')

nmap('<leader>gO', function()
    fzf.git_branches({
        prompt = 'Diff branch> ',
        actions = {
            ['default'] = function(selected)
                diff_view(selected[1])
            end,
        },
    })
end, 'Diff view branch')

gitsigns.setup({
    signcolumn = false,
    numhl = true,
    on_attach = function(bufnr)
        -- Finder
        nmap('<leader>gt', fzf.git_status, 'Status', bufnr)
        nvmap('<leader>gc', fzf.git_bcommits, 'Buffer Commits')
        nmap('<leader>gC', fzf.git_commits, 'All Commits')

        -- Navigation
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
        map({ 'o', 'x' }, 'ig', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk', bufnr)

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
    end,
})
