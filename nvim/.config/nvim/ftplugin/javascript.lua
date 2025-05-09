local dap = require('dap')
local dap_utils = require('dap.utils')
local dap_vscode_js = require('dap-vscode-js')

if not vim.g.js_adapter then
    dap_vscode_js.setup({
        debugger_cmd = 'js-debug-adapter',
        adapters = {
            'pwa-node',
            'pwa-chrome',
            'pwa-msedge',
            'node-terminal',
            'pwa-extensionHost',
        },
    })

    vim.g.js_adapter = true
end

for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
    dap.configurations[language] = {
        {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
        },
        {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach process',
            processId = dap_utils.pick_process,
            cwd = '${workspaceFolder}',
        },
        {
            type = 'pwa-chrome',
            request = 'launch',
            name = 'Start Chrome with "localhost"',
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}',
            userDataDir = '${workspaceFolder}/.vscode/debug',
        },
    }
end
