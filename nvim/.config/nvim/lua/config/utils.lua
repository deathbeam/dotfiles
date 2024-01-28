local wk = require("which-key")

local M = {}

M.nmap = function(keys, func, desc, buffer)
    vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
end

M.desc = function(key, desc)
    wk.register { [key] = { name = desc, _ = 'which_key_ignore' } }
end

return M
