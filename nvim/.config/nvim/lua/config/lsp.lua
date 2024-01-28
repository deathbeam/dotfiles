local nmap = require('config/utils').nmap
local languages = require('config/languages')
local fzf_lua = require('fzf-lua')
local lsp_capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities())

require("which-key").register {
    ['<leader>c'] = { name = "[C]ode", _ = 'which_key_ignore' },
}

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        nmap('K', vim.lsp.buf.hover, 'Documentation', event.buf)
        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition', event.buf)
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration', event.buf)
        nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation', event.buf)
        nmap('go', vim.lsp.buf.type_definition, '[G]oto [O]verload', event.buf)
        nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences', event.buf)
        nmap('gs', vim.lsp.buf.signature_help, '[G]oto [S]ignature Help', event.buf)
        nmap('gl', vim.diagnostic.open_float, '[G]oto [L]ine Diagnostics', event.buf)
        nmap('[d', vim.diagnostic.goto_prev, 'Goto Previous [D]iagnostic', event.buf)
        nmap(']d', vim.diagnostic.goto_next, 'Goto Next [D]iagnostic', event.buf)

        -- find
        nmap('<leader>fd', fzf_lua.lsp_document_diagnostics, '[F]ind [D]iagnostics', event.buf)
        nmap('<leader>fD', fzf_lua.lsp_workspace_diagnostics, '[F]ind All [D]iagnostics', event.buf)
        nmap('<leader>fs', fzf_lua.lsp_document_symbols, '[F]ind [S]ymbols', event.buf)
        nmap('<leader>fS', fzf_lua.lsp_live_workspace_symbols, '[F]ind All [S]ymbols', event.buf)

        -- code
        nmap('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename', event.buf)
        nmap('<leader>cf', vim.lsp.buf.format, '[C]ode [F]ormat', event.buf)
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', event.buf)
    end
})

local lspconfig = require('lspconfig')
require('mason-lspconfig').setup_handlers {
    function(server)
        local settings = nil
        local ignore = nil
        for _, server_config in pairs(languages) do
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
    end
}
