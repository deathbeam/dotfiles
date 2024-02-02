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

vim.cmd [[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.StatusLineActive()
  au User LspProgressStatusUpdated setlocal statusline=%!v:lua.StatusLineActive()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.StatusLineInactive()
  augroup END
]]
