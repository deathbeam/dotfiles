local registry = require('mason-registry')
local python_dap = require('dap-python')
local utils = require('config.utils')
local nmap = utils.nmap
local au = utils.au
local cache_vars = {}

au('FileType', {
    pattern = { 'python' },
    desc = 'Setup python',
    callback = function()
        if not cache_vars.dap_setup then
            cache_vars.dap_setup = true
            python_dap.setup(registry.get_package('debugpy'):get_install_path() .. '/venv/bin/python')
        end

        nmap('<leader>dt', python_dap.test_method, 'Debug Test Method', 0)
        nmap('<leader>dT', python_dap.test_class, 'Debug Test Class', 0)
    end,
})
