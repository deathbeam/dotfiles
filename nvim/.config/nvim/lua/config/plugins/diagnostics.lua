local utils = require('config.utils')
local au = utils.au
local ns = vim.api.nvim_create_namespace('diagnostic_unnecessary_hl_override')

-- Store original DiagnosticUnnecessary colors to reuse
au('ColorScheme', {
    callback = function()
        local orig_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticUnnecessary' })
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.api.nvim_set_hl(0, 'DiagnosticUnnecessaryOverride', orig_hl)
        vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', {})
    end,
})

local lastlnum = nil

au({ 'DiagnosticChanged', 'CursorMoved' }, {
    callback = function(args)
        local bufnr = args.buf

        local lnum = vim.fn.line('.') - 1
        if lnum == lastlnum then
            -- Skip if cursor hasn't moved vertically
            return
        end
        lastlnum = lnum

        -- Clear previous highlights
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

        -- Apply highlights to all unnecessary diagnostics except ones under cursor
        vim.iter(vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }))
            :filter(function(diagnostic)
                return diagnostic._tags and diagnostic._tags.unnecessary
            end)
            :filter(function(diagnostic)
                return lnum < diagnostic.lnum or lnum > diagnostic.end_lnum
            end)
            :each(function(diagnostic)
                vim.api.nvim_buf_set_extmark(bufnr, ns, diagnostic.lnum, diagnostic.col, {
                    hl_group = 'DiagnosticUnnecessaryOverride',
                    end_line = diagnostic.end_lnum,
                    end_col = diagnostic.end_col,
                    priority = 200,
                    strict = false,
                })
            end)
    end,
})
