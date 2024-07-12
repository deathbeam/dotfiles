local wk = require('which-key')
local group = vim.api.nvim_create_augroup('NeoVimRc', { clear = true })

local M = {}

M.dot = function(callback)
    return function()
        _G.dot_repeat_callback = callback
        vim.go.operatorfunc = 'v:lua.dot_repeat_callback'
        vim.cmd('normal! g@l')
    end
end

M.map = function(mode, keys, func, dot, desc, buffer)
    if dot then
        if func then
            local f = func
            func = M.dot(function()
                f()
            end)
        end
        if desc then
            desc = desc .. ' [R]'
        end
    end

    vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc, remap = true, nowait = true })
end

M.nmap = function(keys, func, desc, buffer)
    M.map('n', keys, func, false, desc, buffer)
end

M.rnmap = function(keys, func, desc, buffer)
    M.map('n', keys, func, true, desc, buffer)
end

M.vmap = function(keys, func, desc, buffer)
    M.map('v', keys, func, false, desc, buffer)
end

M.rvmap = function(keys, func, desc, buffer)
    M.map('v', keys, func, true, desc, buffer)
end

M.nvmap = function(keys, func, desc, buffer)
    M.map({ 'n', 'v' }, keys, func, false, desc, buffer)
end

M.rnvmap = function(keys, func, desc, buffer)
    M.map({ 'n', 'v' }, keys, func, true, desc, buffer)
end

M.au = function(event, opts)
    opts['group'] = group
    return vim.api.nvim_create_autocmd(event, opts)
end

M.desc = function(key, desc)
    wk.add({ key, desc = desc })
end

M.make_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('autocomplete.capabilities'))
    return capabilities
end

return M
