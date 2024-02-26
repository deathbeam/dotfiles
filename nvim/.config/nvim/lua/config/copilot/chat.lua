local Copilot = require("config.copilot.copilot")

local M = {}
local state = {
    copilot = nil,
    window = {
        id = nil,
        bufnr = nil
    }
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

    vim.api.nvim_buf_set_lines(bufnr, last_separator_line + 1, #lines, false, {''})
    return vim.trim(table.concat(result, "\n"))
end

local function open_win()
    if not state.window.bufnr or not vim.api.nvim_buf_is_valid(state.window.bufnr) then
        state.window.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(state.window.bufnr, "copilot-chat")
        vim.bo[state.window.bufnr].filetype = 'markdown'
        vim.treesitter.start(state.window.bufnr, 'markdown')
        vim.keymap.set('n', '<CR>', function()
            local input = find_after_last_separator(state.window.bufnr, "---")
            vim.print(input)
            if input ~= "" then
                M.ask(input)
            end
        end, { buffer = state.window.bufnr })
    end

    if not state.window.id or not vim.api.nvim_win_is_valid(state.window.id) then
        state.window.id = vim.api.nvim_open_win(state.window.bufnr, false, {
            vertical = true,
            style = 'minimal',
            height=1
        })

        vim.wo[state.window.id].wrap = true
        vim.wo[state.window.id].linebreak = true
        vim.wo[state.window.id].cursorline = true
        vim.wo[state.window.id].conceallevel = 2
        vim.wo[state.window.id].concealcursor = 'niv'
    end
end

local function close_win()
    if state.window.id and vim.api.nvim_win_is_valid(state.window.id) then
        vim.api.nvim_win_close(state.window.id, true)
        state.window.id = nil
    end
end

local function get_selection(start, finish)
  local start_line, start_col = start[2], start[3]
  local finish_line, finish_col = finish[2], finish[3]

  if start_line > finish_line or (start_line == finish_line and start_col > finish_col) then
    start_line, start_col, finish_line, finish_col = finish_line, finish_col, start_line, start_col
  end

  local lines = vim.fn.getline(start_line, finish_line)
  if #lines == 0 then
    return
  end
  lines[#lines] = string.sub(lines[#lines], 1, finish_col)
  lines[1] = string.sub(lines[1], start_col)
  return lines
end

local function get_current_expression()
    if vim.fn.mode() == "v" then
        local start = vim.fn.getpos("v")
        local finish = vim.fn.getpos(".")
        local lines = get_selection(start, finish)
        if not lines then
            return ""
        end
        return table.concat(lines, "\n")
    end
    return vim.fn.expand("<cexpr>")
end

local function append(str)
    vim.schedule(function()
        local last_line = vim.api.nvim_buf_line_count(state.window.bufnr) - 1
        local last_line_content = vim.api.nvim_buf_get_lines(state.window.bufnr, -2, -1, false)
        local last_column = vim.fn.strdisplaywidth(last_line_content[1])
        vim.api.nvim_win_set_cursor(state.window.id, {last_line + 1, last_column})
        vim.api.nvim_buf_set_text(state.window.bufnr, last_line, last_column, last_line, last_column, vim.split(str, "\n"))
    end)
end

function M.ask(str)
    open_win()
    local expression = get_current_expression()
    local filetype = vim.bo.filetype

    return state.copilot:ask(str, {
        code_excerpt = expression,
        code_language = filetype,
        on_progress = append,
        on_done = function()
            append("\n\n---\n\n")
        end
    })
end

function M.setup()
    state.copilot = Copilot()
end

return M
