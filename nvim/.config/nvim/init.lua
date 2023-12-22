vim.cmd([[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
]])

-- WhichKey
local wk = require("which-key")
wk.register({
  f = { name = "finder" },
  g = { name = "git" },
  e = { name = "edit" },
  r = { name = "refactor" },
  w = { name = "wiki" },
}, { prefix = "<leader>" })
