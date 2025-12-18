local gitsigns = require('gitsigns')
local fzf = require('fzf-lua')
local utils = require('config.utils')
local map = utils.map
local nmap = utils.nmap
local vmap = utils.vmap

-- GitHub permalink command
local function github_permalink()
  local api = vim.api
  local file = api.nvim_buf_get_name(0)
  if file == "" then
    print("No file")
    return
  end
  local cwd = vim.fn.getcwd()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  local relpath = vim.fn.fnamemodify(file, ":.")
  if git_root and git_root ~= "" then
    relpath = vim.fn.fnamemodify(file, ":~:.")
    relpath = vim.fn.systemlist("realpath --relative-to=" .. git_root .. " " .. file)[1]
  end
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  local line = api.nvim_win_get_cursor(0)[1]
  local repo_url = vim.fn.systemlist("gh repo view --json url -q .url")[1]
  if not repo_url or repo_url == "" then
    print("Not a GitHub repo or gh not installed")
    return
  end
  local url = string.format("%s/blob/%s/%s#L%d", repo_url, branch, relpath, line)
  vim.fn.setreg("+", url)
  print("GitHub permalink copied to clipboard:\n" .. url)
end

vim.api.nvim_create_user_command("GitHubLink", github_permalink, {})

-- Enable difftool
vim.cmd.packadd('nvim.difftool')

-- Enable diffmode replacement
-- vim.g.difftool_replace_diff_mode = true

gitsigns.setup({
    signcolumn = false,
    numhl = true,
    watch_gitdir = {
        enable = false,
    },
    on_attach = function(bufnr)
        -- Finder
        nmap('<leader>gt', fzf.git_status, 'Status', bufnr)
        nmap('<leader>gz', fzf.git_stash, 'Stash', bufnr)

        -- Navigation
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
        nmap('<leader>gw', function()
          local diffopt = vim.opt.diffopt:get()
          local has_iwhite = vim.tbl_contains(diffopt, 'iwhite')
          if has_iwhite then
            vim.opt.diffopt:remove('iwhite')
            vim.notify("Whitespace will be shown in diff", vim.log.levels.INFO)
          else
            vim.opt.diffopt:append('iwhite')
            vim.notify("Whitespace will be ignored in diff", vim.log.levels.INFO)
          end
        end, 'Toggle ignore whitespace in diff')
    end,
})
