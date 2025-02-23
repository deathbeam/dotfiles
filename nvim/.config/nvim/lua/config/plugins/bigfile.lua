local au = require('config.utils').au

au('BufReadPre', {
    pattern = '*',
    desc = 'Disable features on big files',
    callback = function(args)
        local bufnr = args.buf
        local size = vim.fn.getfsize(vim.fn.expand('%'))

        if size < 1024 * 1024 then
            return
        end

        vim.api.nvim_buf_set_var(bufnr, 'bigfile_disable', 1)

        -- Disable treesitter
        require('nvim-treesitter.configs').get_module('indent').disable = function()
            return vim.api.nvim_buf_get_var(bufnr, 'bigfile_disable') == 1
        end

        -- Disable autoindent
        vim.bo.indentexpr = ''
        vim.bo.autoindent = false
        vim.bo.smartindent = false
        -- Disable folding
        vim.opt_local.foldmethod = 'manual'
        vim.opt_local.foldexpr = '0'
        -- Disable statuscolumn
        vim.opt_local.statuscolumn = ''
        -- Disable search highlight
        vim.opt_local.hlsearch = false
        -- Disable line wrapping
        vim.opt_local.wrap = false
        -- Disable cursorline
        vim.opt_local.cursorline = false
        -- Disable swapfile
        vim.opt_local.swapfile = false
        -- Disable spell checking
        vim.opt_local.spell = false
    end,
})
