local Copilot = require('config.copilot.copilot')
local spinner = require('config.copilot.spinner')

local M = {}
local state = {
    copilot = nil,
    window = {
        id = nil,
        bufnr = nil,
    },
}

local function find_after_last_separator(bufnr, separator)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local last_separator_line = 0

    -- Find the last occurrence of the separator
    for i, line in ipairs(lines) do
        if string.find(line, separator) then
            last_separator_line = i
        end
    end

    -- Extract everything after the last separator
    local result = {}
    for i = last_separator_line + 1, #lines do
        table.insert(result, lines[i])
    end

    vim.api.nvim_buf_set_lines(bufnr, last_separator_line + 1, #lines, false, { '' })
    return vim.trim(table.concat(result, '\n'))
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
        return
    end

    if not full_lines then
        lines[#lines] = string.sub(lines[#lines], 1, finish_col)
        lines[1] = string.sub(lines[1], start_col)
    end

    return lines
end

local function get_current_selection()
    local mode = vim.fn.mode()
    if mode:lower() == 'v' then
        local start = vim.fn.getpos('v')
        local finish = vim.fn.getpos('.')
        local lines = get_selection_lines(start, finish, mode == 'V')
        if lines then
            return table.concat(lines, '\n')
        end
        return ''
    end
    return vim.fn.getreg('"')
end

local function append(str)
    vim.schedule(function()
        local last_line = vim.api.nvim_buf_line_count(state.window.bufnr) - 1
        local last_line_content = vim.api.nvim_buf_get_lines(state.window.bufnr, -2, -1, false)
        local last_column = #last_line_content[1]
        vim.api.nvim_win_set_cursor(state.window.id, { last_line + 1, last_column })
        vim.api.nvim_buf_set_text(
            state.window.bufnr,
            last_line,
            last_column,
            last_line,
            last_column,
            vim.split(str, '\n')
        )
    end)
end

function M.open()
    if not state.window.bufnr or not vim.api.nvim_buf_is_valid(state.window.bufnr) then
        state.window.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(state.window.bufnr, 'copilot-chat')
        vim.bo[state.window.bufnr].filetype = 'markdown'
        vim.treesitter.start(state.window.bufnr, 'markdown')
        vim.keymap.set('n', '<CR>', function()
            local input = find_after_last_separator(state.window.bufnr, '---')
            if input ~= '' then
                M.ask(input, true)
            end
        end, { buffer = state.window.bufnr })
    end

    if not state.window.id or not vim.api.nvim_win_is_valid(state.window.id) then
        state.window.id = vim.api.nvim_open_win(state.window.bufnr, false, {
            vertical = true,
            style = 'minimal',
            height = 1,
        })

        vim.wo[state.window.id].wrap = true
        vim.wo[state.window.id].linebreak = true
        vim.wo[state.window.id].cursorline = true
        vim.wo[state.window.id].conceallevel = 2
        vim.wo[state.window.id].concealcursor = 'niv'
    end
end

function M.close()
    if state.window.id and vim.api.nvim_win_is_valid(state.window.id) then
        vim.api.nvim_win_close(state.window.id, true)
        state.window.id = nil
    end
end

function M.ask(str, skip_selection)
    M.open()
    local selection = ''
    local filetype = ''

    if not skip_selection then
        selection = get_current_selection()
        filetype = vim.bo.filetype
    end

    return state.copilot:ask(str, {
        code_excerpt = selection,
        code_language = filetype,
        on_start = function()
            spinner.show(state.window.bufnr)
            append('**copilot:** ')
        end,
        on_done = function()
            append('\n\n---\n\n')
            -- This updates cursor to the very end
            append('')
            spinner.hide(
                state.window.bufnr,
                'Ask a question here and then press <CR> in normal mode to send it.',
                -1
            )
        end,
        on_progress = append,
    })
end

function M.reset()
    state.copilot:reset()
    if state.window.bufnr and vim.api.nvim_buf_is_valid(state.window.bufnr) then
        vim.api.nvim_buf_set_lines(state.window.bufnr, 0, -1, true, {})
    end
end

function M.setup()
    state.copilot = Copilot()
end

return M
