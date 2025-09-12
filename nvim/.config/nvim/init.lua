-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

local function r(module)
    local status_ok, loaded_module = pcall(require, module)
    if not status_ok then
        vim.notify('Error loading ' .. module, vim.log.levels.ERROR)
        vim.notify(loaded_module, vim.log.levels.ERROR)
    end
    return loaded_module
end

vim.loader.enable()
r('config.myplugins')
r('config.mason')
r('config.ui')
r('config.finder')
r('config.treesitter')
r('config.lsp')
r('config.dap')
r('config.git')
r('config.copilot')
r('config.statuscolumn')
