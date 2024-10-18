local dap = require('dap')
local dap_utils = require('dap.utils')
local registry = require('mason-registry')

local function dotnet_build_project(callback)
    local path = vim.fn.getcwd() .. '/'
    local cmd = { 'dotnet', 'build', '-c', 'Debug', path }

    vim.api.nvim_out_write('Building project: ' .. table.concat(cmd, ' ') .. '\n')

    local function on_exit(result)
        if result.code == 0 then
            vim.api.nvim_out_write('Build: ✔️\n')
        else
            vim.api.nvim_out_write('Build: ❌ (code: ' .. result.code .. ')\n')
        end

        if callback then
            callback(result.code)
        end
    end

    vim.system(cmd, {
        text = true,
        stdout = vim.schedule_wrap(function(_, data)
            if data then
                vim.api.nvim_out_write(data)
            end
        end),
        stderr = vim.schedule_wrap(function(_, data)
            if data then
                vim.api.nvim_out_write(data)
            end
        end),
    }, vim.schedule_wrap(on_exit))
end

local function dotnet_get_dll_paths()
    return vim.fn.glob(vim.fn.getcwd() .. '/bin/Debug/**/*.dll', false, true)
end

dap.adapters.coreclr = function(callback, _)
    dotnet_build_project(function()
        callback({
            type = 'executable',
            command = registry.get_package('netcoredbg'):get_install_path() .. '/netcoredbg',
            args = { '--interpreter=vscode' },
        })
    end)
end

dap.configurations.cs = {
    {
        type = 'coreclr',
        request = 'attach',
        console = 'integratedTerminal',
        name = 'Attach to process',
        processId = dap_utils.pick_process,
    },
}

for _, dll_path in ipairs(dotnet_get_dll_paths()) do
    table.insert(dap.configurations.cs, {
        type = 'coreclr',
        request = 'launch',
        console = 'integratedTerminal',
        name = 'Launch - ' .. dll_path,
        program = dll_path,
    })
end
