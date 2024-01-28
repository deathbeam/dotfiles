local M = {}

M.nmap = function(keys, func, desc, buffer)
  vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
end

return M
