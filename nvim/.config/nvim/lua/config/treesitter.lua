local packages = vim.iter(require('config.languages'))
    :map(function(server)
        return server.treesitter
    end)
    :filter(function(server)
        return server
    end)
    :flatten()
    :totable()

require('nvim-treesitter.configs').setup({
    ensure_installed = packages,
    sync_install = true,
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
})

vim.treesitter.language.register('bash', 'zsh')
vim.o.foldexpr = 'v:lua.vim.lsp.foldexpr()'

-- Treehopper mappings
vim.cmd([[
    omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
    xnoremap <silent> m :lua require('tsht').nodes()<CR>
]])
