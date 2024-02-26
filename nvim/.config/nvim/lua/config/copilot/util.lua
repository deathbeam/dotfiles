local M = {}

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

return M
