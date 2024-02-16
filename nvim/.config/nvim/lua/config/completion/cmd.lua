local M = {}

local state = {
    timer = nil,
    ns = {
        selection = nil,
        directory = nil,
    },
    completion = {
        current = 0,
        last = nil,
        skip_next = false,
        noselect = false,
        menuone = false,
        data = {}
    },
    window = {
        id = nil,
        bufnr = nil
    }
}

local function open_win(height)
    if not state.window.bufnr or not vim.api.nvim_buf_is_valid(state.window.bufnr) then
        state.window.bufnr = vim.api.nvim_create_buf(false, true)
    end

    if not state.window.id or not vim.api.nvim_win_is_valid(state.window.id) then
        state.window.id = vim.api.nvim_open_win(state.window.bufnr, false, {
            relative = 'editor',
            border = M.config.window.border,
            style = 'minimal',
            width = vim.o.columns,
            height = height,
            row = vim.o.lines - 2,
            col = 0,
        })
    end
end

local function close_win()
    if state.window.id and vim.api.nvim_win_is_valid(state.window.id) then
        vim.api.nvim_win_close(state.window.id, true)
        state.window.id = nil
    end
end

local function is_cmdline()
    return vim.fn.getcmdwintype() == '' and vim.v.event.cmdtype == ':' and vim.fn.mode() == 'c'
end

local function highlight_selection()
    if state.completion.current < 1 or state.completion.current > #state.completion.data then
        return
    end

    if not M.config.highlight.selection then
        return
    end

    vim.api.nvim_buf_clear_namespace(state.window.bufnr, state.ns.selection, 0, -1)
    vim.highlight.range(
        state.window.bufnr,
        state.ns.selection,
        'PmenuSel',
        state.completion.data[state.completion.current].start,
        state.completion.data[state.completion.current].finish,
        {}
    )
end

local function update_cmdline(accept, reset)
    if vim.tbl_isempty(state.completion.data) then
        return
    end

    if state.completion.current > #state.completion.data then
        state.completion.current = 1
    end
    if state.completion.current < 1 then
        state.completion.current = #state.completion.data
    end

    if accept or reset then
        if M.config.close_on_done then
            state.completion.skip_next = true
            close_win()
        end
    else
        state.completion.skip_next = not accept
    end

    if reset then
        vim.fn.setcmdline(state.completion.last)
        return
    end

    highlight_selection()
    vim.cmd('redraw')

    local commands = vim.split(vim.fn.getcmdline(), ' ')
    table.remove(commands, #commands)
    local new_cmdline = table.concat(commands, ' ') .. ' ' .. state.completion.data[state.completion.current].completion
    new_cmdline = vim.trim(new_cmdline)
    if accept and not M.config.close_on_done then
        new_cmdline = new_cmdline .. (vim.endswith(new_cmdline, '/') and '' or ' ')
    end

    vim.fn.setcmdline(new_cmdline)
end

local function cmdline_changed()
    -- We are currently updating command line via next/prev, so do not refresh it
    if state.completion.skip_next then
        state.completion.skip_next = false
        return
    end

    local window_height = M.config.window.rows
    if window_height < 1 then
        window_height = math.floor(vim.o.lines * window_height)
    end

    local col_width = math.floor(vim.o.columns / M.config.window.columns)

    -- Recreate window if we closed it before
    open_win(window_height)

    -- Clear window
    local window_data = {}
    for _ = 0, window_height do
        window_data[#window_data + 1] = (' '):rep(vim.o.columns)
    end
    vim.api.nvim_buf_set_lines(state.window.bufnr, 0, window_height, false, window_data)

    -- Get completions
    local input = vim.fn.getcmdline()
    local completions = vim.fn.getcompletion(input, 'cmdline')

    state.completion.last = input
    state.completion.data = {}
    state.completion.current = state.completion.noselect and 0 or 1

    if #completions <= (state.completion.menuone and 0 or 1) then
        close_win()
        return
    end

    local i = 1
    for line = 0, window_height - 1 do
        for col = 0, math.floor(vim.o.columns / col_width) - 1 do
            if i > #completions then
                break
            end

            local completion = completions[i]
            local is_directory = vim.fn.isdirectory(vim.fn.fnamemodify(completion, ':p')) == 1

            local shortened = vim.fn.fnamemodify(completion, ':p:t')
            if shortened == '' then
                shortened = vim.fn.fnamemodify(completion, ':p:h:t')
            end
            if is_directory then
                shortened = shortened .. '/'
            end
            shortened = ' ' .. shortened .. ' '

            if string.len(shortened) >= col_width then
                shortened = string.sub(shortened, 1, col_width - 4) .. '...'
            end

            local end_col = col * col_width + string.len(shortened)
            if end_col > vim.o.columns then
                break
            end

            vim.api.nvim_buf_set_text(state.window.bufnr, line, col * col_width, line, end_col, { shortened })

            local data = {
                start = { line, col * col_width },
                finish = { line, end_col },
                completion = completion,
            }

            state.completion.data[i] = data
            if M.config.highlight.directories and is_directory then
                vim.highlight.range(
                    state.window.bufnr,
                    state.ns.directory,
                    'Directory',
                    data.start,
                    data.finish,
                    {}
                )
            end

            i = i + 1
        end
    end

    vim.api.nvim_win_set_height(state.window.id, math.min(math.floor(#completions / (math.floor(vim.o.columns / col_width))), window_height))
    highlight_selection()
    vim.cmd('redraw')
end

local function changed_handlers()
    if not is_cmdline() then
        return
    end

    state.timer:stop()
    state.timer:start(M.config.debounce_delay, 0, vim.schedule_wrap(cmdline_changed))
end

local function setup_handlers()
    if not is_cmdline() then
        return
    end

    state.completion.menuone = string.find(vim.o.completeopt, 'menuone')
    state.completion.noselect = string.find(vim.o.completeopt, 'noselect')
    changed_handlers()
end

local function teardown_handlers()
    state.timer:stop()
    state.completion.data = {}
    state.completion.last = nil

    if state.window.id and vim.api.nvim_win_is_valid(state.window.id) then
        vim.api.nvim_win_close(state.window.id, true)
        state.window.id = nil
    end
end

M.config = {
    window = {
        border = nil,
        columns = 5,
        rows = 0.3
    },
    mappings = {
        accept = '<C-y>',
        reject = '<C-e>',
        complete = '<C-space>',
        next = '<C-n>',
        previous = '<C-p>',
    },
    highlight = {
        selection = true,
        directories = true,
    },
    debounce_delay = 100,
    close_on_done = true, -- Close completion window when done (accept/reject)
}

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    -- Wild menu needs to be always disabled otherwise its in background for no reason
    vim.o.wildmenu = false

    state.timer = vim.uv.new_timer()
    state.ns.selection = vim.api.nvim_create_namespace('CmdlineCompletionSelection')
    state.ns.directory = vim.api.nvim_create_namespace('CmdlineCompletionDirectory')

    if M.config.mappings.accept then
        vim.keymap.set('c', M.config.mappings.accept, function()
            update_cmdline(true)
        end, { desc = 'Accept cmdline completion' })
    end
    if M.config.mappings.reject then
        vim.keymap.set('c', M.config.mappings.reject, function()
            update_cmdline(false, true)
        end, { desc = 'Reject cmdline completion' })
    end
    if M.config.mappings.complete then
        vim.keymap.set('c', M.config.mappings.complete, function()
            cmdline_changed()
        end, { desc = 'Force complete cmdline completion' })
    end
    if M.config.mappings.next then
        vim.keymap.set('c', M.config.mappings.next, function()
            state.completion.current = state.completion.current + 1
            update_cmdline()
        end, { desc = 'Next cmdline completion' })
    end
    if M.config.mappings.previous then
        vim.keymap.set('c', M.config.mappings.previous, function()
            state.completion.current = state.completion.current - 1
            update_cmdline()
        end, { desc = 'Previous cmdline completion' })
    end

    local group = vim.api.nvim_create_augroup('CmdlineCompletion', {})
    vim.api.nvim_create_autocmd('CmdwinEnter', {
        desc = 'Tear down cmdline completion handlers',
        group = group,
        callback = teardown_handlers,
    })
    vim.api.nvim_create_autocmd('CmdlineEnter', {
        desc = 'Setup cmdline completion handlers',
        group = group,
        callback = setup_handlers,
    })
    vim.api.nvim_create_autocmd('CmdlineLeave', {
        desc = 'Tear down cmdline completion handlers',
        group = group,
        callback = teardown_handlers,
    })
    vim.api.nvim_create_autocmd('CmdlineChanged', {
        desc = 'Auto update cmdline completion',
        group = group,
        callback = changed_handlers,
    })
end

return M
