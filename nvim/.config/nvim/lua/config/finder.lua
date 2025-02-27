local utils = require('config.utils')
local nmap = utils.nmap
local nvmap = utils.nvmap
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

-- https://github.com/ibhagwan/fzf-lua/issues/602
local function w(fn)
    return function(...)
        return fn({
            ignore_current_line = true,
            jump1 = true,
            includeDeclaration = false,
        }, ...)
    end
end

vim.lsp.handlers['textDocument/codeAction'] = w(fzf_lua.lsp_code_actions)

nmap('<leader>fg', fzf_lua.live_grep_glob, 'Find Grep')
nmap('<leader>fG', function()
    fzf_lua.live_grep_glob({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, 'Find Git Grep')
nmap('<leader>fr', fzf_lua.resume, 'Find Resume')
nmap('<leader>ff', fzf_lua.files, 'Find Files')
nmap('<leader>fF', fzf_lua.git_files, 'Find Git Files')
nmap('<leader>fa', fzf_lua.commands, 'Find Actions')
nvmap('<leader>fc', fzf_lua.git_bcommits, 'Find Commits')
nmap('<leader>fC', fzf_lua.git_commits, 'Find All Commits')
nmap('<leader>fB', fzf_lua.git_blame, 'Find Blame')
nmap('<leader>fb', fzf_lua.buffers, 'Find Buffers')
nmap('<leader>fh', fzf_lua.oldfiles, 'Find History')
nmap('<leader>fk', fzf_lua.keymaps, 'Find Keymaps')
nmap('<leader>fq', fzf_lua.quickfix, 'Find Quickfix')
nmap('<leader>f?', fzf_lua.helptags, 'Find Help')
nmap('<leader>fj', fzf_lua.jumps, 'Find Jumps')
nmap('<leader>fm', fzf_lua.marks, 'Find Marks')
nmap('<leader>fd', fzf_lua.lsp_document_diagnostics, 'Find Diagnostics')
nmap('<leader>fD', fzf_lua.lsp_workspace_diagnostics, 'Find all Diagnostics')
nmap('<leader>fs', fzf_lua.lsp_document_symbols, 'Find Symbols')
nmap('<leader>fS', fzf_lua.lsp_live_workspace_symbols, 'Find all Symbols')

-- Show undo history with diffs
local function undo_history()
    if not vim.api.nvim_get_option_value('modifiable', { buf = 0 }) then
        print('Current buffer is not modifiable.')
        return
    end

    local undotree = vim.fn.undotree()
    local entries = {}
    local cur_seq = undotree.seq_cur
    local cur_cursor = vim.api.nvim_win_get_cursor(0)

    -- Build entries from undotree
    for _, entry in ipairs(undotree.entries) do
        -- Save current buffer state
        if not pcall(vim.cmd, 'silent undo ' .. entry.seq) then
            goto continue
        end
        local buffer_after = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

        -- Get parent state
        if not pcall(vim.cmd, 'silent undo') then
            goto continue
        end
        local buffer_before = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

        local diff = vim.diff(buffer_before, buffer_after, {
            ctxlen = 3,
            algorithm = 'minimal',
        })

        -- Add header and count changes
        if diff and #diff > 0 then
            local additions = 0
            local deletions = 0
            for line in diff:gmatch('[^\r\n]+') do
                if line:match('^%+') and not line:match('^%+%+%+') then
                    additions = additions + 1
                elseif line:match('^%-') and not line:match('^%-%-%-') then
                    deletions = deletions + 1
                end
            end

            table.insert(entries, {
                seq = entry.seq,
                time = os.date('%H:%M:%S', entry.time),
                additions = additions,
                deletions = deletions,
                diff = diff,
            })
        end

        ::continue::
    end

    -- Restore original state
    vim.cmd('silent undo ' .. cur_seq)
    vim.api.nvim_win_set_cursor(0, cur_cursor)

    -- Show in fzf
    fzf_lua.fzf_exec(function(cb)
        for i = #entries, 1, -1 do
            local entry = entries[i]
            local changes = ''
            if entry.additions > 0 then
                changes = changes .. fzf_lua.utils.ansi_codes.green('+' .. entry.additions)
            end
            if entry.deletions > 0 then
                if changes ~= '' then
                    changes = changes .. ' '
                end
                changes = changes .. fzf_lua.utils.ansi_codes.red('-' .. entry.deletions)
            end
            local time = fzf_lua.utils.ansi_codes.magenta(entry.time)
            cb(string.format('[%-4s] %-8s %-8s\t%s', entry.seq, time, changes, entry.diff))
        end
    end, {
        prompt = 'Undo History❯ ',
        actions = {
            ['default'] = function(selected)
                local seq = selected[1]:match('%[(%d+)%s*%]')
                vim.cmd('silent undo ' .. seq)
            end,
        },
        fzf_opts = {
            ['--delimiter'] = '\t',
            ['--preview'] = 'echo {2} | bat --style=plain --color=always --language diff',
            ['--preview-window'] = 'right:50%:wrap',
            ['--with-nth'] = '1',
        },
    })
end

nmap('<leader>fu', undo_history, 'Find Undo History')
