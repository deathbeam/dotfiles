local fzf_lua = require('fzf-lua')

local M = {}

local function get_entry(entry, cur_seq)
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

    -- Format for display
    local changes = ''
    if additions > 0 then
        changes = changes .. fzf_lua.utils.ansi_codes.green('+' .. additions)
    end
    if deletions > 0 then
        if changes ~= '' then
            changes = changes .. ' '
        end
        changes = changes .. fzf_lua.utils.ansi_codes.red('-' .. deletions)
    end

    local time = fzf_lua.utils.ansi_codes.magenta(os.date('%H:%M:%S', entry.time))
    local is_current = entry.seq == cur_seq and fzf_lua.utils.ansi_codes.yellow(' ●') or ''
    return string.format('%d\t%-10s %-10s%s\t%s', entry.seq, time, changes, is_current, diff)
end

function M.undo_history()
    if not vim.bo.modifiable then
        return
    end

    local undotree = vim.fn.undotree()
    local cur_seq = undotree.seq_cur

    if not undotree.entries or #undotree.entries == 0 then
        return
    end

    -- Show in fzf
    fzf_lua.fzf_exec(function(fzf_cb)
        -- Save view state
        local view = vim.fn.winsaveview()

        -- Process entries from newest to oldest
        for i = #undotree.entries, 1, -1 do
            fzf_cb(get_entry(undotree.entries[i], cur_seq))
        end

        -- Restore original state
        vim.cmd('silent noautocmd undo ' .. cur_seq)
        vim.fn.winrestview(view)

        -- EOF
        fzf_cb()
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
