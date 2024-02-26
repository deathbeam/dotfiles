local M = {}

local ns = vim.api.nvim_create_namespace('spinner')
local spinner_frames = {
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
}

local spinner_index = 1
local spinner_timer = nil

local function set(bufnr, text, offset)
    offset = offset or 0
    vim.api.nvim_buf_set_extmark(bufnr, ns, vim.api.nvim_buf_line_count(bufnr) - 1 + offset, 0, {
        id = ns,
        virt_text = { { text, 'DiagnosticSignHint' } },
        virt_text_pos = offset ~= 0 and 'inline' or 'eol',
        hl_mode = 'combine',
        priority = 100,
    })
end

function M.start(bufnr)
    spinner_timer = vim.loop.new_timer()
    spinner_timer:start(
        0,
        100,
        vim.schedule_wrap(function()
            set(bufnr, spinner_frames[spinner_index])
            spinner_index = spinner_index % #spinner_frames + 1
        end)
    )
end

function M.finish(bufnr, replacement, offset)
    if spinner_timer then
        spinner_timer:stop()
        spinner_timer:close()
        spinner_timer = nil
        vim.schedule(function()
            if replacement then
                set(bufnr, replacement, offset)
            else
                vim.api.nvim_buf_del_extmark(bufnr, ns, ns)
            end
        end)
    end
end

return M
