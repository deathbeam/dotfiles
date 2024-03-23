local fzf_lua = require('fzf-lua')
local languages = require('config.languages')
local utils = require('config.utils')
local nmap = utils.nmap
local desc = utils.desc
local au = utils.au
local lsp_capabilities = utils.make_capabilities()

desc('<leader>c', 'Code')

-- Set signs
for name, icon in pairs(require('config.icons').diagnostics) do
    vim.fn.sign_define('DiagnosticSign' .. name, { text = icon, texthl = 'Diagnostic' .. name })
end

-- Set borders
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
vim.diagnostic.config({ severity_sort = true, float = { border = 'single' } })

-- Set diagnostic mappings
nmap('gl', vim.diagnostic.open_float, 'Goto Line Diagnostics')
nmap('[d', vim.diagnostic.goto_prev, 'Goto previous Diagnostic')
nmap(']d', vim.diagnostic.goto_next, 'Goto next Diagnostic')

require('lspecho').setup()

au('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        if client.server_capabilities.inlayHintProvider or client.server_capabilities.signatureHelpProvider then
            vim.lsp.inlay_hint.enable(event.buf, true)
        end

        if client.server_capabilities.hoverProvider then
            nmap('K', vim.lsp.buf.hover, 'Documentation', event.buf)
        end
        if client.server_capabilities.definitionProvider then
            nmap('gd', vim.lsp.buf.definition, 'Goto Definition', event.buf)
        end
        if client.server_capabilities.declarationProvider then
            nmap('gD', vim.lsp.buf.declaration, 'Goto Declaration', event.buf)
        end
        if client.server_capabilities.implementationProvider then
            nmap('gi', vim.lsp.buf.implementation, 'Goto Implementation', event.buf)
        end
        if client.server_capabilities.typeDefinitionProvider then
            nmap('go', vim.lsp.buf.type_definition, 'Goto Overload', event.buf)
        end
        if client.server_capabilities.referencesProvider then
            nmap('gr', vim.lsp.buf.references, 'Goto References', event.buf)
        end
        if client.server_capabilities.signatureHelpProvider then
            nmap('gs', vim.lsp.buf.signature_help, 'Goto Signature Help', event.buf)
        end

        -- find
        nmap('<leader>fd', fzf_lua.lsp_document_diagnostics, 'Find Diagnostics', event.buf)
        nmap('<leader>fD', fzf_lua.lsp_workspace_diagnostics, 'Find all Diagnostics', event.buf)
        nmap('<leader>fs', fzf_lua.lsp_document_symbols, 'Find Symbols', event.buf)
        nmap('<leader>fS', fzf_lua.lsp_live_workspace_symbols, 'Find all Symbols', event.buf)

        -- code
        nmap('<leader>cr', vim.lsp.buf.rename, 'Code Rename', event.buf)
        nmap('<leader>cf', vim.lsp.buf.format, 'Code Format', event.buf)
        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action', event.buf)
    end,
})

local lspconfig = require('lspconfig')
require('mason-lspconfig').setup_handlers({
    function(server)
        local settings = nil
        local ignore = nil
        for _, server_config in ipairs(languages) do
            if server_config.mason and vim.tbl_contains(server_config.mason, server) then
                settings = server_config.lsp_settings
                ignore = server_config.lsp_ignore
            end
        end
        if ignore then
            return
        end
        lspconfig[server].setup({
            capabilities = lsp_capabilities,
            settings = settings,
        })
    end,
})
