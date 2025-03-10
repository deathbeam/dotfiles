local utils = require('config.utils')
local fzf = require('config.plugins.fzf')
local nmap = utils.nmap
local desc = utils.desc

desc('<leader>f', 'Find')

local fzf_lua = require('fzf-lua')
fzf_lua.setup({
    'fzf-tmux',
    file_icon_padding = ' ',
    fzf_opts = {
        ['--info'] = false,
        ['--border'] = false,
        ['--preview-window'] = 'border-sharp',
        ['--tmux'] = '100%,100%',
    },
    defaults = {
        formatter = 'path.filename_first',
        multiline = 1,
    },
    grep = {
        rg_opts = ' --hidden --glob "!.git/" --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
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

fzf_lua.register_ui_select({
    fzf_opts = {
        ['--tmux'] = 'bottom,50%',
    },
})

nmap('<leader><leader>', fzf_lua.resume, 'Find Resume')
nmap('<leader>fg', fzf_lua.live_grep_glob, 'Find Grep')
nmap('<leader>fG', function()
    fzf_lua.live_grep_glob({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, 'Find Git Grep')
nmap('<leader>ff', fzf_lua.files, 'Find Files')
nmap('<leader>fF', fzf_lua.git_files, 'Find Git Files')
nmap('<leader>fa', fzf_lua.commands, 'Find Actions')
nmap('<leader>fb', fzf_lua.buffers, 'Find Buffers')
nmap('<leader>fh', fzf_lua.oldfiles, 'Find History')
nmap('<leader>fk', fzf_lua.keymaps, 'Find Keymaps')
nmap('<leader>fq', fzf_lua.quickfix, 'Find Quickfix')
nmap('<leader>f?', fzf_lua.helptags, 'Find Help')
nmap('<leader>fj', fzf_lua.jumps, 'Find Jumps')
nmap('<leader>fm', fzf_lua.marks, 'Find Marks')
nmap('<leader>fu', fzf.undo_history, 'Find Undo History')
