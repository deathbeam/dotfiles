local utils = require('config.utils')
local nmap = utils.nmap
local nvmap = utils.nvmap
local desc = utils.desc

desc('<leader>f', 'Find')

local fzf = require('fzf-lua')
fzf.setup({
    'fzf-tmux',
    file_icon_padding = ' ',
    winopts = {
        border = 'none',
        preview = {
            border = 'single'
        }
    },
    fzf_opts = {
        ['--info'] = false,
        ['--border'] = false,
        ['--tmux'] = '100%,100%',
    },
    defaults = {
        formatter = 'path.filename_first',
        multiline = 1,
    },
    files = {
        rg_opts = ' --files --hidden --ignore --glob "!.git" --sortr=modified',
        fzf_opts = {
            ["--scheme"] = "path",
            ["--tiebreak"] = "index",
            -- ["--schema"] = "history"
        },
    },
    grep = {
        rg_opts = ' --hidden --ignore --glob "!.git/" --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
        prompt = 'Grep❯ ',
        no_column_hide = true,
    },
    lsp = {
        code_actions = {
            fzf_opts = {
                ['--tmux'] = 'bottom,50%',
            },
        },
    },
    dap = {
        configurations = {
            fzf_opts = {
                ['--tmux'] = 'bottom,50%',
            },
        },
    },
    oldfiles = {
        include_current_session = true,
        cwd_only = true,
        stat_file = true,
    },
})

fzf.register_ui_select({
    fzf_opts = {
        ['--tmux'] = 'bottom,50%',
    },
})

nmap('<leader><leader>', fzf.resume, 'Find Resume')
nmap('<leader>fg', fzf.live_grep, 'Find Grep')
nmap('<leader>ff', fzf.files, 'Find Files')
nmap('<leader>fa', fzf.commands, 'Find Actions')
nmap('<leader>fb', fzf.buffers, 'Find Buffers')
nmap('<leader>fh', fzf.oldfiles, 'Find History')
nmap('<leader>fk', fzf.keymaps, 'Find Keymaps')
nmap('<leader>fq', fzf.quickfix, 'Find Quickfix')
nmap('<leader>f?', fzf.helptags, 'Find Help')
nmap('<leader>fj', fzf.jumps, 'Find Jumps')
nmap('<leader>fm', fzf.marks, 'Find Marks')

-- Git
nmap('<leader>fG', function()
    fzf.live_grep({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, 'Find Git Grep')
nmap('<leader>fF', fzf.git_files, 'Find Git Files')
nvmap('<leader>fc', fzf.git_bcommits, 'Find Buffer Git Commits')
nmap('<leader>fC', fzf.git_commits, 'Find All Git Commits')

-- LSP
nmap('<leader>fd', fzf.lsp_document_diagnostics, 'Find Diagnostics')
nmap('<leader>fD', fzf.lsp_workspace_diagnostics, 'Find All Diagnostics')
nmap('<leader>fs', fzf.lsp_document_symbols, 'Find Symbols')
nmap('<leader>fS', fzf.lsp_live_workspace_symbols, 'Find All Symbols')
