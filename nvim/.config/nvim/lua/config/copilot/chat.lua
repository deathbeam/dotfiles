local Copilot = require('config.copilot.copilot')
local Spinner = require('config.copilot.spinner')

local M = {}
local state = {
    buffer = nil,
    selection = nil,
    filetype = nil,

    copilot = nil,
    spinner = nil,
    window = {
        id = nil,
        bufnr = nil,
    },
}

local function find_lines_between_separator_at_cursor(bufnr, separator)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]
    local line_count = #lines
    local last_separator_line = 1
    local next_separator_line = line_count

    -- Find the last occurrence of the separator
    for i, line in ipairs(lines) do
        if i > cursor_line and string.find(line, separator) then
            next_separator_line = i - 1
            break
        end
        if string.find(line, separator) then
            last_separator_line = i + 1
        end
    end

    -- Extract everything between the last and next separator
    local result = {}
    for i = last_separator_line, next_separator_line do
        table.insert(result, lines[i])
    end

    return vim.trim(table.concat(result, '\n')),
        last_separator_line,
        next_separator_line,
        line_count
end

local function get_selection_lines(start, finish, full_lines)
    local start_line, start_col = start[2], start[3]
    local finish_line, finish_col = finish[2], finish[3]

    if start_line > finish_line or (start_line == finish_line and start_col > finish_col) then
        start_line, start_col, finish_line, finish_col =
            finish_line, finish_col, start_line, start_col
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, finish_line, false)
    if #lines == 0 then
        return nil, 0, 0, 0, 0
    end

    if full_lines then
        start_col = 0
        finish_col = #lines[#lines]
    else
        lines[#lines] = string.sub(lines[#lines], 1, finish_col)
        lines[1] = string.sub(lines[1], start_col)
    end

    return table.concat(lines, '\n'), start_line, start_col, finish_line, finish_col
end

local function get_current_selection()
    local mode = vim.fn.mode()
    if mode:lower() == 'v' then
        local start = vim.fn.getpos('v')
        local finish = vim.fn.getpos('.')
        -- Switch to vim normal mode from visual mode
        vim.api.nvim_feedkeys('<Esc>', 'n', true)
        local lines, start_row, start_col, end_row, end_col =
            get_selection_lines(start, finish, mode == 'V')
        return {
            lines = lines,
            start_row = start_row,
            start_col = start_col,
            end_row = end_row,
            end_col = end_col,
        }
    end
    return {
        lines = vim.fn.getreg('"'),
    }
end

local function append(str)
    vim.schedule(function()
        if not vim.api.nvim_win_is_valid(state.window.id) then
            state.copilot:stop()
            return
        end

        local last_line = vim.api.nvim_buf_line_count(state.window.bufnr) - 1
        local last_line_content = vim.api.nvim_buf_get_lines(state.window.bufnr, -2, -1, false)
        local last_column = #last_line_content[1]
        vim.api.nvim_buf_set_text(
            state.window.bufnr,
            last_line,
            last_column,
            last_line,
            last_column,
            vim.split(str, '\n')
        )

        -- Get new position of text and update cursor
        last_line = vim.api.nvim_buf_line_count(state.window.bufnr) - 1
        last_line_content = vim.api.nvim_buf_get_lines(state.window.bufnr, -2, -1, false)
        last_column = #last_line_content[1]
        vim.api.nvim_win_set_cursor(state.window.id, { last_line + 1, last_column })
    end)
end

local function show_help()
    if not state.spinner then
        return
    end

    state.spinner:finish()
    append('\n')
    state.spinner:set(
        "Press 'q' to close, '<Esc>' to clear, "
            .. "'<CR>' on top of prompt to submit prompt, "
            .. "'<C-y>' on top of code block to apply the diff",
        -1
    )
end

function M.open(opts)
    opts = opts or {}
    local just_created = false

    if not state.window.bufnr or not vim.api.nvim_buf_is_valid(state.window.bufnr) then
        state.window.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(state.window.bufnr, 'copilot-chat')
        vim.bo[state.window.bufnr].filetype = 'markdown'
        vim.treesitter.start(state.window.bufnr, 'markdown')

        vim.keymap.set('n', '<Esc>', M.reset, { buffer = state.window.bufnr })
        vim.keymap.set('n', 'q', M.close, { buffer = state.window.bufnr })
        vim.keymap.set('n', '<CR>', function()
            local input, start_line, end_line, line_count =
                find_lines_between_separator_at_cursor(state.window.bufnr, '---')
            if input ~= '' then
                -- If we are entering the input at the end, replace it
                if line_count == end_line then
                    vim.api.nvim_buf_set_lines(
                        state.window.bufnr,
                        start_line,
                        end_line,
                        false,
                        { '' }
                    )
                end
                M.ask(input, {
                    selection = state.selection,
                    filetype = state.filetype,
                    buffer = state.buffer,
                })
            end
        end, { buffer = state.window.bufnr })
        vim.keymap.set('n', '<C-y>', function()
            if not state.buffer or not state.selection.start_row or not state.selection.end_row then
                return
            end

            local input = find_lines_between_separator_at_cursor(state.window.bufnr, '```')
            if input ~= '' then
                vim.api.nvim_buf_set_text(
                    state.buffer,
                    state.selection.start_row - 1,
                    state.selection.start_col,
                    state.selection.end_row - 1,
                    state.selection.end_col,
                    vim.split(input, '\n')
                )
            end
        end, { buffer = state.window.bufnr })
        just_created = true
    end

    if not state.spinner then
        state.spinner = Spinner(state.window.bufnr)
    end

    if not state.window.id or not vim.api.nvim_win_is_valid(state.window.id) then
        local win_opts = {
            style = 'minimal',
        }

        local layout = opts.layout or 'vertical'

        if layout == 'vertical' then
            win_opts.vertical = true
        elseif layout == 'horizontal' then
            win_opts.vertical = false
        elseif layout == 'float' then
            win_opts.relative = 'editor'
            win_opts.border = opts.border or 'single'
            win_opts.title = opts.title or "Copilot Chat ('q' to close, '<Esc>' to clear)"
            win_opts.row = math.floor(vim.o.lines * 0.2)
            win_opts.col = math.floor(vim.o.columns * 0.1)
            win_opts.width = math.floor(vim.o.columns * 0.8)
            win_opts.height = math.floor(vim.o.lines * 0.6)
        end

        state.window.id = vim.api.nvim_open_win(state.window.bufnr, false, win_opts)
        vim.wo[state.window.id].wrap = true
        vim.wo[state.window.id].linebreak = true
        vim.wo[state.window.id].cursorline = true
        vim.wo[state.window.id].conceallevel = 2
        vim.wo[state.window.id].concealcursor = 'niv'

        if just_created then
            show_help()
        end
    end

    vim.api.nvim_set_current_win(state.window.id)
end

function M.close()
    if state.window.id and vim.api.nvim_win_is_valid(state.window.id) then
        vim.api.nvim_win_close(state.window.id, true)
        state.window.id = nil
    end

    if state.spinner then
        state.spinner:finish()
        state.spinner = nil
    end

    state.copilot:stop()
end

function M.ask(str, opts)
    opts = opts or {}
    state.buffer = opts.buffer or vim.api.nvim_get_current_buf()
    state.selection = opts.selection or get_current_selection()
    state.filetype = opts.filetype or vim.bo.filetype
    M.open(opts)

    return state.copilot:ask(str, {
        selection = state.selection.lines,
        filetype = state.filetype,
        system_prompt = opts.system_prompt,
        model = opts.model,
        temperature = opts.temperature,
        on_start = function()
            state.spinner:start()
            append('**copilot:** ')
        end,
        on_done = function()
            append('\n\n---\n')
            show_help()
        end,
        on_progress = append,
        on_error = function(err)
            vim.print(err)
        end,
    })
end

function M.reset()
    state.copilot:reset()
    if state.window.bufnr and vim.api.nvim_buf_is_valid(state.window.bufnr) then
        vim.api.nvim_buf_set_lines(state.window.bufnr, 0, -1, true, {})
    end
    show_help()
end

function M.setup()
    state.copilot = Copilot()
end

return M
