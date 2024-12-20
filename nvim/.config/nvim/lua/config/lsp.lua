local languages = require('config.languages')
local utils = require('config.utils')
local nmap = utils.nmap
local au = utils.au
local lsp_capabilities = utils.make_capabilities()

-- Echo LSP messages
require('lspecho').setup()

-- Debug print
require('debugprint').setup()

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
        -- Check if there's any visible floating window
        local has_float = false
        for _, win in pairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(win).relative ~= '' then
                has_float = true
                break
            end
        end

        -- Only show diagnostic float if no floating window is visible
        if not has_float then
            vim.diagnostic.open_float()
        end
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

        -- enable completion
        -- vim.lsp.completion.enable(true, client.id, event.buf, {
        --     autotrigger = true
        -- })

        -- if client.server_capabilities.inlayHintProvider or client.server_capabilities.signatureHelpProvider then
        nmap('gh', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
        end, 'Inlay Hints', event.buf)
        -- end

        -- if client.server_capabilities.hoverProvider then
        nmap('K', vim.lsp.buf.hover, 'Documentation', event.buf)
        -- end
        -- if client.server_capabilities.definitionProvider or client.server_capabilities.declarationProvider then
        nmap('gd', vim.lsp.buf.definition, 'Goto Definition', event.buf)
        nmap('gD', vim.lsp.buf.declaration, 'Goto Declaration', event.buf)
        -- end
        -- if client.server_capabilities.referencesProvider then
        nmap('gr', vim.lsp.buf.references, 'Goto References', event.buf)
        -- end
        -- if client.server_capabilities.implementationProvider then
        nmap('gi', vim.lsp.buf.implementation, 'Goto Implementation', event.buf)
        -- end
        -- if client.server_capabilities.typeDefinitionProvider then
        nmap('gy', vim.lsp.buf.type_definition, 'Goto Type Definition', event.buf)
        -- end

        -- code refactor
        nmap('crf', vim.lsp.buf.format, 'Code Format', event.buf)
        nmap('cra', vim.lsp.buf.code_action, 'Code Actions', event.buf)
        nmap('crr', vim.lsp.buf.rename, 'Code Rename', event.buf)
    end,
})

-- Setup LSP servers
local lspconfig = require('lspconfig')
for _, language in ipairs(languages) do
    for _, lsp in ipairs(language.lsp or {}) do
        lspconfig[lsp].setup({
            cmd = language.cmd,
            capabilities = lsp_capabilities,
            settings = language.settings,
        })
    end
end
