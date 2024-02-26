local util = require('config.copilot.util')

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

local Spinner = util.class(function(self, bufnr)
    self.ns = vim.api.nvim_create_namespace('spinner')
    self.bufnr = bufnr
    self.timer = nil
    self.index = 1
end)

function Spinner:set(text, offset)
    offset = offset or 0
    vim.api.nvim_buf_set_extmark(
        self.bufnr,
        self.ns,
        vim.api.nvim_buf_line_count(self.bufnr) - 1 + offset,
        0,
        {
            id = self.ns,
            virt_text = { { text, 'DiagnosticSignHint' } },
            virt_text_pos = offset ~= 0 and 'inline' or 'eol',
            hl_mode = 'combine',
            priority = 100,
        }
    )
end

function Spinner:start()
    self.timer = vim.loop.new_timer()
    self.timer:start(
        0,
        100,
        vim.schedule_wrap(function()
            if not vim.api.nvim_buf_is_valid(self.bufnr) then
                self:finish()
                return
            end

            self:set(spinner_frames[self.index])
            self.index = self.index % #spinner_frames + 1
        end)
    )
end

function Spinner:finish(replacement, offset)
    if self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
        vim.schedule(function()
            if replacement then
                self:set(replacement, offset)
            elseif vim.api.nvim_buf_is_valid(self.bufnr) then
                vim.api.nvim_buf_del_extmark(self.bufnr, self.ns, self.ns)
            end
        end)
    end
end

return Spinner
