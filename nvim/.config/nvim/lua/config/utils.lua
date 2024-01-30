local wk = require("which-key")

local M = {}

M.dot = function(callback)
    return function()
        _G.dot_repeat_callback = callback
        vim.go.operatorfunc = "v:lua.dot_repeat_callback"
        vim.cmd("normal! g@l")
    end
end

M.map = function(mode, keys, func, dot, desc, buffer)
    if dot then
        if func then
            local f = func
            func = M.dot(function() f() end)
        end
        if desc then
            desc = desc .. " [R]"
        end
    end

    vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc })
end

M.nmap = function(keys, func, desc, buffer)
    M.map("n", keys, func, false, desc, buffer)
end

M.rnmap = function(keys, func, desc, buffer)
    M.map("n", keys, func, true, desc, buffer)
end

M.vmap = function(keys, func, desc, buffer)
    M.map("v", keys, func, false, desc, buffer)
end

M.rvmap = function(keys, func, desc, buffer)
    M.map("v", keys, func, true, desc, buffer)
end

M.nvmap = function(keys, func, desc, buffer)
    M.map({"n", "v"}, keys, func, false, desc, buffer)
end

M.rnvmap = function(keys, func, desc, buffer)
    M.map({"n", "v"}, keys, func, true, desc, buffer)
end

M.desc = function(key, desc)
    wk.register { [key] = { name = desc, _ = "which_key_ignore" } }
end

M.inlay_hints = function(buf, value)
    local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
    if type(ih) == "function" then
        ih(buf, value)
    elseif type(ih) == "table" and ih.enable then
        if value == nil then
            value = not ih.is_enabled(buf)
        end
        ih.enable(buf, value)
    end
end

return M
