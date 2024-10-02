return require('dap.ui').new_view(function()
    return vim.api.nvim_create_buf(false, true)
end, function(buf)
    vim.cmd('split')
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    return win
end)
