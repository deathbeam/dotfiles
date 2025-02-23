-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

require('config.plugins.bigfile')
require('config.plugins.rooter')
require('config.plugins.session')
require('config.plugins.wiki')

require('config.mason')
require('config.ui')
require('config.statuscolumn')
require('config.finder')
require('config.treesitter')
require('config.completion')
require('config.lsp')
require('config.dap')
require('config.git')
require('config.copilot')
