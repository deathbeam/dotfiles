local au = require("config.utils").au
local lspprogress = require('lsp-progress')
lspprogress.setup()

function StatusLineActive()
    return table.concat {
        -- color 1
        [[%1*]],
        -- file format
        [[ %{&ff}]],
        -- file type
        [[%y]],
        -- full path
        [[ %<%F]],
        -- modified flag 
        [[%m ]],
        -- color 2
        [[%2*]],
        -- left/right separator
        [[%= ]],
        -- lsp progress
        lspprogress.progress(),
        -- color 3
        [[ %3*]],
        -- cursor info
        [[ %l/%L-%v 0x%04B ]]
    }
end

function StatusLineInactive()
    return table.concat {
        -- file format
        [[ %{&ff}]],
        -- file type
        [[%y]],
        -- full path
        [[ %<%F]],
        -- modified flag 
        [[ %m]],
    }
end

au("User", {
    pattern = {"LspProgressStatusUpdated"},
    callback = function()
        vim.cmd("redrawstatus!")
    end
})

au({"WinEnter", "BufEnter"}, {
    pattern = {"*"},
    callback = function()
        vim.opt_local.statusline = "%!v:lua.StatusLineActive()"
    end
})

au({"WinLeave","BufLeave"}, {
    pattern = {"*"},
    callback = function()
        vim.opt_local.statusline = "%!v:lua.StatusLineInactive()"
    end
})
