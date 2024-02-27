local M = {}

--- Create class
--- @param fn function The class constructor
--- @return table
function M.class(fn)
    local out = {}
    out.__index = out
    setmetatable(out, {
        __call = function(cls, ...)
            return cls.new(...)
        end,
    })

    function out.new(...)
        local self = setmetatable({}, out)
        fn(self, ...)
        return self
    end
    return out
end

--- Create custom command
--- @param cmd string The command name
--- @param func function The function to execute
--- @param opt table The options
M.create_cmd = function(cmd, func, opt)
    opt = vim.tbl_extend('force', { desc = 'CopilotChat.nvim ' .. cmd }, opt or {})
    vim.api.nvim_create_user_command(cmd, func, opt)
end

return M
