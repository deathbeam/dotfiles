-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

local function r(module)
    local ok, mod = pcall(require, module)
    if not ok then
        vim.notify(('Error loading %s: %s'):format(module, mod), vim.log.levels.ERROR)
        return nil
    end
    return mod
end

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
