local M = {
    selected_env = nil,
    http_window = nil,
    http_buffer = nil,
}

local function ensure_buffer()
    if M.http_buffer and vim.api.nvim_buf_is_valid(M.http_buffer) then
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].syntax = 'http_stat'
    M.http_buffer = buf
end

local function exec(file, line, env)
    local cmd = {
        "httpyac",
        file
    }

    if line then
        table.insert(cmd, "-l")
        table.insert(cmd, line)
    end

    if env then
        table.insert(cmd, "-e")
        table.insert(cmd, env)
    end

    ensure_buffer()
    vim.api.nvim_buf_set_lines(M.http_buffer, 0, -1, false, {})
    vim.system(cmd, {
        text = true,
        stdout = vim.schedule_wrap(function(err, data)
            if not data then
                return
            end

            local lines = vim.split(data, '\n')
            local line_count = vim.api.nvim_buf_line_count(M.http_buffer)
            vim.api.nvim_buf_set_lines(M.http_buffer, line_count, line_count, false, lines)
        end)
    })
end

function M.open()
    if M.http_window and vim.api.nvim_win_is_valid(M.http_window) then
        vim.api.nvim_set_current_win(M.http_window)
        return
    end

    ensure_buffer()
    vim.cmd("botright vsplit")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, M.http_buffer)
    M.http_window = win
end

function M.close()
    if M.http_window and vim.api.nvim_win_is_valid(M.http_window) then
        vim.api.nvim_win_close(M.http_window, true)
        M.http_window = nil
    end
end

function M.toggle()
    if M.http_window and vim.api.nvim_win_is_valid(M.http_window) then
        M.close()
    else
        M.open()
    end
end

function M.run_all()
    local file = vim.fn.expand('%:p')
    exec(file, nil, M.selected_env)
end

function M.run()
    local file = vim.fn.expand('%:p')
    local line = vim.fn.line('.')
    exec(file, line, M.selected_env)
end

function M.select_env()
    local current_file = vim.fn.expand('%:p')
    local current_dir = vim.fn.fnamemodify(current_file, ':h')
    local filename = current_dir .. '/http-client.env.json'
    local env_file = io.open(filename, "r")

    if not env_file then
        vim.notify("Environment file not found: " .. filename, vim.log.levels.ERROR)
        return
    end

    local content = env_file:read("*all")
    env_file:close()

    local env_data = vim.json.decode(content)
    if not env_data then
        vim.notify("Failed to parse environment file", vim.log.levels.ERROR)
        return
    end

    local envs = {}
    for env_name, _ in pairs(env_data) do
        table.insert(envs, env_name)
    end
    table.sort(envs)

    vim.ui.select(envs, {
        prompt = "Select environment:",
    }, function(choice)
        if choice then
            M.selected_env = choice
            vim.notify("Selected environment: " .. choice, vim.log.levels.INFO)
        end
    end)
end

return M
