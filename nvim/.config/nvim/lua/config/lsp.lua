local fzf = require('fzf-lua')
local languages = require('config.languages')
local icons = require('config.icons')
local utils = require('config.utils')
local nmap = utils.nmap
local au = utils.au
local desc = utils.desc
local lsp_capabilities = utils.make_capabilities()

local function w(fn)
    return function(...)
        return fn({
            ignore_current_line = true,
            jump1 = true,
            includeDeclaration = false,
        }, ...)
    end
end

vim.diagnostic.config({
    severity_sort = true,
    virtual_text = false,
    virtual_lines = {
        current_line = true,
    },
    float = {
        border = 'single',
        focusable = false,
    },
    jump = {
        _highest = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.Error,
            [vim.diagnostic.severity.WARN] = icons.Warn,
            [vim.diagnostic.severity.INFO] = icons.Info,
            [vim.diagnostic.severity.HINT] = icons.Hint,
        },
    },
})

-- Setup LSP mappings
-- :h lsp-defaults
au('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client or string.find(client.name:lower(), 'copilot') then
            return
        end

        -- enable lsp folding
        if client:supports_method('textDocument/foldingRange') then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        -- disable semantic tokens
        client.server_capabilities.semanticTokensProvider = nil

        -- lsp mappings
        desc('<leader>c', 'Code')
        nmap('<leader>cr', vim.lsp.buf.rename, 'Rename', event.buf)
        nmap('<leader>ch', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, 'Inlay Hints', event.buf)
        nmap('<leader>ca', w(fzf.lsp_code_actions), 'Code Action', event.buf)
        nmap('<leader>cd', w(fzf.lsp_document_diagnostics), 'Diagnostics')
        nmap('<leader>cD', w(fzf.lsp_workspace_diagnostics), 'All Diagnostics')
        nmap('<leader>cs', w(fzf.lsp_document_symbols), 'Symbols')
        nmap('<leader>cS', w(fzf.lsp_live_workspace_symbols), 'All Symbols')

        nmap('gr', w(fzf.lsp_references), 'References', event.buf)
        nmap('gi', w(fzf.lsp_implementations), 'Implementation', event.buf)
        nmap('gd', w(fzf.lsp_definitions), 'Definition', event.buf)
        nmap('gD', w(fzf.lsp_declarations), 'Declaration', event.buf)
        nmap('gy', w(fzf.lsp_typedefs), 'Type Definition', event.buf)
    end,
})

-- Setup LSP servers
local lspconfig = require('lspconfig')
for _, language in ipairs(languages) do
    if language.setup then
        language.setup()
    end

    for _, lsp in ipairs(language.lsp or {}) do
        lspconfig[lsp].setup({
            cmd = language.cmd,
            capabilities = lsp_capabilities,
            settings = language.settings,
        })
    end
end
