require('nvim-treesitter.configs').setup({
    ensure_installed = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(
        function(server)
            return server.treesitter
        end,
        vim.tbl_filter(function(server)
            return server.treesitter
        end, require('config.languages'))
    ))),
    sync_install = true,
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
})

vim.treesitter.language.register('bash', 'zsh')

vim.cmd([[
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
]])

-- Treehopper mappings
vim.cmd([[
    omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
    xnoremap <silent> m :lua require('tsht').nodes()<CR>
]])
