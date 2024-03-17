local registry = require('mason-registry')
local lspconfig = require('lspconfig')
local python_dap = require('dap-python')
local utils = require('config.utils')
local languages = require('config.languages')
local nmap = utils.nmap
local au = utils.au
local lsp_capabilities = utils.make_capabilities()
local cache_vars = {}

local function python_setup()
    if not cache_vars.dap_setup then
        cache_vars.dap_setup = true
        local path = registry.get_package('debugpy'):get_install_path()
        path = path .. '/venv/bin/python'
        python_dap.setup(path)
    end

    nmap('<leader>dt', python_dap.test_method, 'Debug Test Method', 0)
    nmap('<leader>dT', python_dap.test_class, 'Debug Test Class', 0)
end

lspconfig['basedpyright'].setup({
    capabilities = lsp_capabilities,
    settings = vim.tbl_filter(function(language)
        return vim.tbl_contains(language.language, 'python')
    end, languages)[1].lsp_settings,
})

au('FileType', {
    pattern = { 'python' },
    desc = 'Setup python',
    callback = python_setup,
})
