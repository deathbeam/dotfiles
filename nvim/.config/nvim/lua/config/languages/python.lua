local nmap = require('config/utils').nmap
local registry = require('mason-registry')
local python_dap = require('dap-python')

local function python_setup()
    local path = registry.get_package('debugpy'):get_install_path()
    path = path .. '/venv/bin/python'
    python_dap.setup(path)
    local bufnr = 0
    nmap('<leader>dt', python_dap.test_method, '[D]ebug [T]est Method', bufnr)
    nmap('<leader>dT', python_dap.test_class, '[D]ebug [T]est Class', bufnr)
end


vim.api.nvim_create_autocmd('FileType', {
    pattern = {'python'},
    desc = 'Setup python',
    callback = python_setup,
})
