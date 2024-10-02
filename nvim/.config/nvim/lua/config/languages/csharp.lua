local dap = require('dap')
local dap_utils = require('dap.utils')
local utils = require('config.utils')
local registry = require('mason-registry')
local au = utils.au

local function dotnet_build_project()
    local path = vim.fn.getcwd() .. '/'
    local cmd = 'dotnet build -c Debug ' .. path .. ' > /dev/null'
    print('Building project: ' .. cmd)
    local f = os.execute(cmd)
    if f == 0 then
        print('\nBuild: ✔️ ')
    else
        print('\nBuild: ❌ (code: ' .. f .. ')')
    end
end

local function dotnet_get_dll_paths()
    return vim.fn.glob(vim.fn.getcwd() .. '/bin/Debug/**/*.dll', false, true)
end

au('FileType', {
    pattern = { 'cs' },
    desc = 'Setup csharp',
    callback = function()
        dap.adapters.coreclr = {
            type = 'executable',
            command = registry.get_package('netcoredbg'):get_install_path() .. '/netcoredbg',
            args = { '--interpreter=vscode' },
        }

        dap.configurations.cs = {
            {
                type = 'coreclr',
                name = 'Attach',
                request = 'attach',
                processId = dap_utils.pick_process,
            },
        }

        for _, dll_path in ipairs(dotnet_get_dll_paths()) do
            table.insert(dap.configurations.cs, {
                type = 'coreclr',
                name = 'launch - ' .. dll_path,
                request = 'launch',
                program = function()
                    dotnet_build_project()
                    return dll_path
                end,
            })
        end
    end,
})
