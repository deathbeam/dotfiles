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

--- Show a spinner virtual text
---@param bufnr integer
function M.show(bufnr)
    spinner_timer = vim.loop.new_timer()
    spinner_timer:start(
        0,
        100,
        vim.schedule_wrap(function()
            vim.api.nvim_buf_set_extmark(bufnr, ns, vim.api.nvim_buf_line_count(bufnr) - 1, 0, {
                id = ns,
                virt_text = { { spinner_frames[spinner_index], 'DiagnosticSignHint' } },
                virt_text_pos = 'eol',
                hl_mode = 'combine',
                priority = 100,
            })
            spinner_index = spinner_index % #spinner_frames + 1
        end)
    )
end

--- Hide the spinner.
---@param bufnr integer
function M.hide(bufnr)
    if spinner_timer then
        spinner_timer:stop()
        spinner_timer:close()
        spinner_timer = nil
        vim.schedule(function()
            vim.api.nvim_buf_del_extmark(bufnr, ns, ns)
        end)
    end
end

return M
