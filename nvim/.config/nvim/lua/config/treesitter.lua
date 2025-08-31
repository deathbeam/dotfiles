local packages = vim.iter(require('config.languages'))
    :map(function(server)
        return server.treesitter
    end)
    :filter(function(server)
        return server
    end)
    :flatten()
    :totable()

vim.api.nvim_create_user_command('TSUpdateSync', function()
    vim.notify('Syncing treesitter parsers...', vim.log.levels.INFO)
    local ts = require('nvim-treesitter')
    local installed = ts.get_installed()
    local to_install = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
    end, packages)
    local to_uninstall = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(packages, lang)
    end, installed)
    if #to_uninstall > 0 then
        ts.uninstall(to_uninstall):wait(300000)
    end
    if #installed > 0 then
        ts.update(installed):wait(300000)
    end
    if #to_install > 0 then
        ts.install(to_install):wait(300000)
    end
    vim.notify('Successfully synced ' .. #packages .. ' parsers.', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
        local ft = vim.bo.filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start()
        end
    end,
})

vim.treesitter.language.register('bash', 'zsh')
vim.o.foldexpr = 'v:lua.vim.lsp.foldexpr()'

-- Treehopper mappings
vim.cmd([[
    omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
    xnoremap <silent> m :lua require('tsht').nodes()<CR>
]])
