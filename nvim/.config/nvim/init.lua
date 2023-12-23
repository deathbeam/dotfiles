vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
]])

-- WhichKey
require("which-key").register({
  f = { name = "finder" },
  g = { name = "git" },
  e = { name = "edit" },
  r = { name = "refactor" },
  w = { name = "wiki" },
}, { prefix = "<leader>" })

-- Treesitter
require("nvim-treesitter.configs").setup {
  ensure_installed = { "css", "html", "javascript", "typescript", "markdown", "lua", "python", "java" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
}

-- Oil
require("oil").setup()
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
