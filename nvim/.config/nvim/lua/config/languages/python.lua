local registry = require('mason-registry')
local python_dap = require('dap-python')
local utils = require('config.utils')
local lspconfig = require('lspconfig')
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

local function exepath(expr)
	local ep = vim.fn.exepath(expr)
	return ep ~= "" and ep or nil
end

lspconfig.pylance.setup {
    capabilities = lsp_capabilities,
    before_init = function(_, config)
        if not config.settings.python then
            config.settings.python = {}
        end
        if not config.settings.python.pythonPath then
            config.settings.python.pythonPath = exepath("python3") or exepath("python") or "python"
        end
    end
}

au('FileType', {
    pattern = { 'python' },
    desc = 'Setup python',
    callback = python_setup,
})
