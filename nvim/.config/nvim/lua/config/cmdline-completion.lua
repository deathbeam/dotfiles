local M = {}

local H = {
    already_setup = false,
    timer = nil,
    ns = {
        selection = nil,
        directory = nil,
    },
    completion = {
        current = 0,
        skip_next = false,
        noselect = false,
        menuone = false,
        data = {}
    },
    window = {
        id = nil,
        bufnr = nil,
        width = 0,
        height = 0,
        data = {}
    }
}

M.config = {
    window = {
        border = nil,
        columns = 5,
        rows = 0.3
    },
    mappings = {
        accept = '<C-y>',
        reject = '<C-e>',
        next = '<C-n>',
        previous = '<C-p>',
    },
    highlight = {
        selection = true,
        directories = true,
    },
    set_vim_settings = true, -- Disable wildmenu and map wildchar to next completion
}

local function open_win()
    if not H.window.bufnr then
        H.window.bufnr = vim.api.nvim_create_buf(false, true)
    end

    if not H.window.id then
        H.window.id = vim.api.nvim_open_win(H.window.bufnr, false, {
            relative = 'editor',
            border = M.config.window.border,
            style = 'minimal',
            width = vim.o.columns,
            height = H.window.height,
            row = vim.o.lines - 2,
            col = 0,
        })
    end
end

local function close_win()
    if H.window.id then
        vim.api.nvim_win_close(H.window.id, true)
        H.window.id = nil
    end
end

local function is_cmdline()
    return vim.fn.getcmdwintype() == '' and vim.v.event.cmdtype == ':'
end

local function highlight_selection()
    if H.completion.current < 1 or H.completion.current > #H.completion.data then
        return
    end

    if not M.config.highlight.selection then
        return
    end

    vim.api.nvim_buf_clear_namespace(H.window.bufnr, H.ns.selection, 0, -1)
    vim.highlight.range(
        H.window.bufnr,
        H.ns.selection,
        'PmenuSel',
        H.completion.data[H.completion.current].start,
        H.completion.data[H.completion.current].finish,
        {}
    )

    vim.cmd('redraw')
end

local function update_cmdline(accept)
    if vim.tbl_isempty(H.completion.data) then
        return
    end

    if H.completion.current > #H.completion.data then
        H.completion.current = 1
    end
    if H.completion.current < 1 then
        H.completion.current = #H.completion.data
    end

    highlight_selection()

    H.completion.skip_next = not accept
    local commands = vim.split(vim.fn.getcmdline(), ' ')
    table.remove(commands, #commands)
    local new_cmdline = table.concat(commands, ' ') .. ' ' .. H.completion.data[H.completion.current].completion
    new_cmdline = vim.trim(new_cmdline)
    if accept then
        new_cmdline = new_cmdline .. (vim.endswith(new_cmdline, '/') and '' or ' ')
    end

    vim.fn.setcmdline(new_cmdline)
end

local function cmdline_changed()
    -- We are currently updating command line via next/prev, so do not refresh it
    if H.completion.skip_next then
        H.completion.skip_next = false
        return
    end

    -- Recreate window if we closed it before
    open_win()

    -- Clear window
    vim.api.nvim_buf_set_lines(H.window.bufnr, 0, H.window.height, false, H.window.data)

    -- Get completions
    local input = vim.fn.getcmdline()
    local completions = vim.fn.getcompletion(input, 'cmdline')

    H.completion.data = {}
    H.completion.current = H.completion.noselect and 0 or 1

    if #completions <= (H.completion.menuone and 0 or 1) then
        close_win()
        return
    end

    local i = 1
    for line = 0, H.window.height - 1 do
        for col = 0, math.floor(vim.o.columns / H.window.width) - 1 do
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

            if string.len(shortened) >= H.window.width then
                shortened = string.sub(shortened, 1, H.window.width - 3) .. '...'
            end

            local end_col = col * H.window.width + string.len(shortened)
            if end_col > vim.o.columns then
                break
            end

            vim.api.nvim_buf_set_text(H.window.bufnr, line, col * H.window.width, line, end_col, { shortened })

            local data = {
                start = { line, col * H.window.width },
                finish = { line, end_col },
                completion = completion,
            }

            H.completion.data[i] = data
            if M.config.highlight.directories and is_directory then
                vim.highlight.range(
                    H.window.bufnr,
                    H.ns.directory,
                    'Directory',
                    data.start,
                    data.finish,
                    {}
                )
            end

            i = i + 1
        end
    end

    vim.api.nvim_win_set_height(H.window.id, math.min(math.floor(#completions / (math.floor(vim.o.columns / H.window.width))), H.window.height))
    highlight_selection()
end

local function setup_handlers()
    if not is_cmdline() then
        return
    end

    H.completion.menuone = string.find(vim.o.completeopt, 'menuone')
    H.completion.noselect = string.find(vim.o.completeopt, 'noselect')

    H.window.height = M.config.window.rows
    if H.window.height < 1 then
        H.window.height = math.floor(vim.o.lines * H.window.height)
    end

    H.window.width = math.floor(vim.o.columns / M.config.window.columns)
    H.window.data = {}
    for _ = 0, H.window.height do
        H.window.data[#H.window.data + 1] = (' '):rep(vim.o.columns)
    end

    cmdline_changed()
end

local function teardown_handlers()
    H.timer:stop()
    H.window.data = {}
    H.completion.data = {}
    local in_cmdwin = vim.fn.getcmdwintype() ~= ''

    if H.window.id then
        -- FIXME: wait for nvim-0.10.0 so this is not needed, lower versions do not allow win_close in cmdwin
        if in_cmdwin and vim.fn.has('nvim-0.10.0') == 0 then
            vim.api.nvim_win_hide(H.window.id)
        else
            vim.api.nvim_win_close(H.window.id, true)
        end
        H.window.id = nil
    end

    if H.window.bufnr then
        vim.api.nvim_buf_set_lines(H.window.bufnr, 0, -1, true, {})
    end
end

local function changed_handlers()
    if not is_cmdline() then
        return
    end

    H.timer:stop()
    H.timer:start(100, 0, vim.schedule_wrap(cmdline_changed))
end

function M.setup(config)
    if H.already_setup then
        return
    end

    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    if M.config.set_vim_settings then
        vim.o.wildmenu = false
    end

    H.timer = vim.loop.new_timer()
    H.ns.selection = vim.api.nvim_create_namespace('CmdlineCompletionSelection')
    H.ns.directory = vim.api.nvim_create_namespace('CmdlineCompletionDirectory')

    if M.config.mappings.accept then
        vim.keymap.set('c', M.config.mappings.accept, function()
            update_cmdline(true)
        end, { desc = 'Accept cmdline completion' })
    end
    if M.config.mappings.reject then
        vim.keymap.set('c', M.config.mappings.reject, function()
            close_win()
        end, { desc = 'Reject cmdline completion' })
    end
    if M.config.mappings.next then
        vim.keymap.set('c', M.config.mappings.next, function()
            H.completion.current = H.completion.current + 1
            update_cmdline()
        end, { desc = 'Next cmdline completion' })
    end
    if M.config.mappings.previous then
        vim.keymap.set('c', M.config.mappings.previous, function()
            H.completion.current = H.completion.current - 1
            update_cmdline()
        end, { desc = 'Previous cmdline completion' })
    end

    local augroup = vim.api.nvim_create_augroup('CmdlineCompletion', {})
    vim.api.nvim_create_autocmd('CmdwinEnter', {
        desc = 'Tear down cmdline completion handlers',
        group = augroup,
        callback = teardown_handlers,
    })
    vim.api.nvim_create_autocmd('CmdlineEnter', {
        desc = 'Setup cmdline completion handlers',
        group = augroup,
        callback = setup_handlers,
    })
    vim.api.nvim_create_autocmd('CmdlineLeave', {
        desc = 'Tear down cmdline completion handlers',
        group = augroup,
        callback = teardown_handlers,
    })
    vim.api.nvim_create_autocmd('CmdlineChanged', {
        desc = 'Auto update cmdline completion',
        group = augroup,
        callback = changed_handlers,
    })
end

return M
