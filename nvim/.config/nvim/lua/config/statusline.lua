local au = require('config.utils').au

function StatusLineActive()
    return table.concat({
        -- prefix
        [[%2*]],
        '──',
        -- color 1
        [[%1*]],
        -- file type
        [[ %y]],
        -- modified flag
        [[%m]],
        -- full path
        [[ %<%F ]],
        -- color 2
        [[%2*]],
        -- left/right separator
        [[%=]],
        -- color 3
        [[%3*]],
        -- cursor info
        [[ %l/%L-%v 0x%04B ]],
        -- suffix
        [[%2*]],
        '──',
    })
end

function StatusLineInactive()
    return table.concat({
        -- prefix
        '──',
        -- file type
        [[ %y]],
        -- modified flag
        [[%m]],
        -- full path
        [[ %<%F ]],
    })
end

vim.cmd([[
set fillchars=stl:─,stlnc:─
]])

au({ 'WinEnter', 'BufEnter' }, {
    pattern = { '*' },
    callback = function()
        vim.opt_local.statusline = '%!v:lua.StatusLineActive()'
    end,
})

au({ 'WinLeave', 'BufLeave' }, {
    pattern = { '*' },
    callback = function()
        vim.opt_local.statusline = '%!v:lua.StatusLineInactive()'
    end,
})
