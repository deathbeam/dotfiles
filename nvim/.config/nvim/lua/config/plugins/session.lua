local config = {
    dirs = {
        vim.fn.expand('~/git'),
    },
}

local au = require('config.utils').au
local session_dir = vim.fn.stdpath('data') .. '/sessions/'
vim.fn.mkdir(session_dir, 'p')

local function get_session_file()
    local cwd = vim.fn.getcwd()
    vim.notify('Checking session for directory: ' .. cwd, vim.log.levels.DEBUG)

    -- Check if current directory is in allowed_dirs
    local is_allowed = false
    for _, dir in ipairs(config.dirs) do
        if string.match(cwd, '^' .. dir) then
            is_allowed = true
            break
        end
    end

    if not is_allowed then
        return nil
    end

    return session_dir .. cwd:gsub('/', '_') .. '.vim'
end

au('VimLeavePre', {
    desc = 'Save session on exit',
    callback = function()
        local session_file = get_session_file()
        if session_file then
            vim.notify('Saving session to: ' .. session_file, vim.log.levels.INFO)
            vim.cmd('mksession! ' .. session_file)
        end
    end,
})

au('VimEnter', {
    desc = 'Restore session on enter',
    callback = function()
        if vim.fn.argc() == 0 then
            local session_file = get_session_file()
            if session_file and vim.fn.filereadable(session_file) == 1 then
                vim.notify('Loading session from: ' .. session_file, vim.log.levels.INFO)
                vim.cmd('silent! source ' .. session_file)
                vim.cmd('silent! doautoall BufRead')
                vim.cmd('silent! doautoall FileType')
                vim.cmd('silent! doautoall BufEnter')
            end
        end
    end,
})
