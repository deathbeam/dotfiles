local fzf_lua = require('fzf-lua')

local M = {}

function M.undo_history()
    if not vim.bo.modifiable then
        return
    end

    local undotree = vim.fn.undotree()
    local entries = {}
    local cur_seq = undotree.seq_cur

    -- Save view state
    local view = vim.fn.winsaveview()

    -- Build entries from undotree
    for _, entry in ipairs(undotree.entries) do
        -- Get state after undo
        vim.cmd('silent noautocmd undo ' .. entry.seq)
        local after = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

        -- Get state before undo
        vim.cmd('silent noautocmd undo')
        local before = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

        -- Calculate diff
        local diff = tostring(vim.diff(before, after, {
            ctxlen = 3,
            algorithm = 'minimal',
        }))

        -- Count changes
        local additions = select(2, diff:gsub('\n%+([^+\n]?)', '')) or 0
        local deletions = select(2, diff:gsub('\n%-([^-\n]?)', '')) or 0

        table.insert(entries, {
            seq = entry.seq,
            time = os.date('%H:%M:%S', entry.time),
            additions = additions,
            deletions = deletions,
            diff = diff,
        })
    end

    -- Restore original state
    vim.cmd('noautocmd silent undo ' .. cur_seq)
    vim.fn.winrestview(view)

    if #entries == 0 then
        return
    end

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
            local is_current = entry.seq == cur_seq and fzf_lua.utils.ansi_codes.yellow(' ●') or ''
            cb(string.format('%d\t%-10s %-10s%s\t%s', entry.seq, time, changes, is_current, entry.diff))
        end
    end, {
        prompt = 'Undo History❯ ',
        actions = {
            ['default'] = function(selected)
                vim.cmd('undo ' .. selected[1]:match('^(%d+)'))
            end,
        },
        fzf_opts = {
            ['--delimiter'] = '\t',
            ['--preview'] = 'echo {3} | bat --style=plain --color=always --language diff',
            ['--preview-window'] = 'right:50%:wrap',
            ['--with-nth'] = '2',
        },
    })
end

return M
