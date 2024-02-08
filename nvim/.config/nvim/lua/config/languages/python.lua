local nmap = require("config.utils").nmap
local registry = require("mason-registry")
local python_dap = require("dap-python")
local cache_vars = {}

local function python_setup()
    if not cache_vars.dap_setup then
        cache_vars.dap_setup = true
        local path = registry.get_package("debugpy"):get_install_path()
        path = path .. "/venv/bin/python"
        python_dap.setup(path)
    end

    nmap("<leader>dt", python_dap.test_method, "[D]ebug [T]est Method", 0)
    nmap("<leader>dT", python_dap.test_class, "[D]ebug [T]est Class", 0)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"python"},
    desc = "Setup python",
    callback = python_setup,
})
