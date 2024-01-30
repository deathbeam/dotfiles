local wk = require("which-key")

local M = {}

M.nmap = function(keys, func, desc, buffer)
    vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
end

M.nvmap = function(keys, func, desc, buffer)
    vim.keymap.set({'n', 'v'}, keys, func, { buffer = buffer, desc = desc })
end

M.vmap = function(keys, func, desc, buffer)
    vim.keymap.set('v', keys, func, { buffer = buffer, desc = desc })
end

M.desc = function(key, desc)
    wk.register { [key] = { name = desc, _ = 'which_key_ignore' } }
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
