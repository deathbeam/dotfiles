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
    self.ns = vim.api.nvim_create_namespace('copilot-spinner')
    self.bufnr = bufnr
    self.timer = nil
    self.index = 1
end)

function Spinner:set(text, offset)
    offset = offset or 0

    vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(self.bufnr) then
            self:finish()
            return
        end

        local line = vim.api.nvim_buf_line_count(self.bufnr) - 1 + offset
        line = math.max(0, line)

        vim.api.nvim_buf_set_extmark(self.bufnr, self.ns, line, 0, {
            id = self.ns,
            virt_text = { { text, 'DiagnosticSignHint' } },
            virt_text_pos = offset ~= 0 and 'inline' or 'eol',
            hl_mode = 'combine',
            priority = 100,
        })
    end)
end

function Spinner:start()
    self.timer = vim.loop.new_timer()
    self.timer:start(0, 100, function()
        self:set(spinner_frames[self.index])
        self.index = self.index % #spinner_frames + 1
    end)
end

function Spinner:finish()
    if self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil

        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(self.bufnr) then
                return
            end

            vim.api.nvim_buf_del_extmark(self.bufnr, self.ns, self.ns)
        end)
    end
end

return Spinner
