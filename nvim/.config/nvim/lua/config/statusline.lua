local au = require("config.utils").au
local icons = require("nvim-web-devicons")

local function get_icon()
    local filename = vim.fn.expand("%:t")
    return icons.get_icon(filename, nil, { default = true })
end

function StatusLineActive()
    return table.concat {
        -- color 1
        [[%1* ]],
        -- icon
        get_icon(),
        -- file type
        [[ %y]],
        -- full path
        [[ %<%F]],
        -- modified flag 
        [[%m ]],
        -- color 2
        [[%2*]],
        -- left/right separator
        [[%= ]],
        -- color 3
        [[ %3*]],
        -- cursor info
        [[ %l/%L-%v 0x%04B ]]
    }
end

function StatusLineInactive()
    return table.concat {
        -- file type
        [[ %y]],
        -- full path
        [[ %<%F]],
        -- modified flag 
        [[ %m]],
    }
end

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
