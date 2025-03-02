local languages = require('config.languages')
local utils = require('config.utils')
local nmap = utils.nmap
local au = utils.au
local desc = utils.desc
local lsp_capabilities = utils.make_capabilities()

-- Echo LSP messages
require('lspecho').setup({
    attach_log = true,
})

-- Configure diagnostics
local icons = require('config.icons').diagnostics
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
vim.diagnostic.config({
    severity_sort = true,
    virtual_text = false,
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

au('CursorHold', {
    desc = 'Show diagnostics',
    callback = function()
        if vim.api.nvim_get_mode().mode ~= 'n' then
            return
        end

        vim.diagnostic.open_float()
    end,
})

-- :h lsp-defaults
au('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client or string.find(client.name:lower(), 'copilot') then
            return
        end

        -- disable semantic tokens
        client.server_capabilities.semanticTokensProvider = nil

        -- lsp mappings
        -- defaults:
        -- gO - document symbol
        -- gq - format
        -- K - hover
        desc('<leader>c', 'Code')
        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action', event.buf)
        nmap('<leader>cc', vim.lsp.codelens.run, 'Code Lens Run', event.buf)
        nmap('<leader>cC', vim.lsp.codelens.refresh, 'Code Lens Refresh', event.buf)
        nmap('<leader>cr', vim.lsp.buf.rename, 'Rename', event.buf)
        nmap('<leader>cd', vim.diagnostic.setqflist, 'Diagnostics', event.buf)
        nmap('<leader>ch', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
        end, 'Inlay Hints', event.buf)

        nmap('gr', vim.lsp.buf.references, 'References', event.buf)
        nmap('gi', vim.lsp.buf.implementation, 'Implementation', event.buf)
        nmap('gd', vim.lsp.buf.definition, 'Definition', event.buf)
        nmap('gD', vim.lsp.buf.declaration, 'Declaration', event.buf)
        nmap('gy', vim.lsp.buf.type_definition, 'Type Definition', event.buf)
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
