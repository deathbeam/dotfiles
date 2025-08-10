local utils = require('config.utils')
local nmap = utils.nmap
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
nmap('<leader>fG', function()
    fzf.live_grep({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, 'Find Git Grep')
nmap('<leader>ff', fzf.files, 'Find Files')
nmap('<leader>fF', fzf.git_files, 'Find Git Files')
nmap('<leader>fa', fzf.commands, 'Find Actions')
nmap('<leader>fb', fzf.buffers, 'Find Buffers')
nmap('<leader>fh', fzf.oldfiles, 'Find History')
nmap('<leader>fk', fzf.keymaps, 'Find Keymaps')
nmap('<leader>fq', fzf.quickfix, 'Find Quickfix')
nmap('<leader>f?', fzf.helptags, 'Find Help')
nmap('<leader>fj', fzf.jumps, 'Find Jumps')
nmap('<leader>fm', fzf.marks, 'Find Marks')
