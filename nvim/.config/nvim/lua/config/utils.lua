local group = vim.api.nvim_create_augroup('NeoVimRc', { clear = true })

local M = {}

M.dot = function(callback)
    return function()
        _G.dot_repeat_callback = callback
        vim.go.operatorfunc = 'v:lua.dot_repeat_callback'
        vim.cmd('normal! g@l')
    end
end

M.map = function(mode, keys, func, desc, buffer, dot)
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
    M.map('n', keys, func, desc, buffer)
end

M.rnmap = function(keys, func, desc, buffer)
    M.map('n', keys, func, desc, buffer, true)
end

M.vmap = function(keys, func, desc, buffer)
    M.map('v', keys, func, desc, buffer)
end

M.rvmap = function(keys, func, desc, buffer)
    M.map('v', keys, func, desc, buffer, true)
end

M.nvmap = function(keys, func, desc, buffer)
    M.map({ 'n', 'v' }, keys, func, desc, buffer)
end

M.rnvmap = function(keys, func, desc, buffer)
    M.map({ 'n', 'v' }, keys, func, desc, buffer, true)
end

M.au = function(event, opts)
    opts['group'] = group
    return vim.api.nvim_create_autocmd(event, opts)
end

return M
