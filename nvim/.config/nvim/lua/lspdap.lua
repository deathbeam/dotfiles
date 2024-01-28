local nmap = require('utils').nmap
local languages = require('languages')
local fzf_lua = require('fzf-lua')
local lsp_capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities())

require("which-key").register {
    ['<leader>c'] = { name = "[C]ode", _ = 'which_key_ignore' },
    ['<leader>d'] = { name = "[D]ebug", _ = 'which_key_ignore' },
}

-- LSP
local lspconfig = require('lspconfig')
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

-- DAP
local dap, dapui = require("dap"), require("dapui")
require("nvim-dap-virtual-text").setup()
dapui.setup()
dap.listeners.before.attach.dapui_config = dapui.open
dap.listeners.before.launch.dapui_config = dapui.open
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close
nmap('<leader>dx', function()
    dap.disconnect({ terminateDebuggee = true })
    dap.close()
    dapui.close()
end, '[D]ebug E[X]it')
nmap('<leader>dr', dap.restart, '[D]ebug [R]estart')
nmap('<leader>du', dapui.toggle, '[D]ebug [U]I Toggle')
nmap('<leader>dd', dap.continue, '[D]ebug Continue')
nmap('<leader>dj', dap.step_over, '[D]ebug Step Over (down)')
nmap('<leader>dk', dap.step_back, '[D]ebug Step Back (up)')
nmap('<leader>dl', dap.step_into, '[D]ebug Step Into (right)')
nmap('<leader>dh', dap.step_out, '[D]ebug Step Out (left)')
nmap('<leader>db', dap.toggle_breakpoint, '[D]ebug [B]reakpoint')
nmap('<leader>dB', function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, '[D]ebug Conditional [B]reakpoint')
nmap('<leader>fp', fzf_lua.dap_breakpoints, '[F]ind Break[P]oints')

-- Mason
require('mason').setup()
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
require('mason-tool-installer').setup {
    ensure_installed = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(function(server) return server.mason end, vim.tbl_filter(function(server) return server.mason end, languages)))),
    run_on_start = false
}
