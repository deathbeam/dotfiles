local dap = require('dap')
local dap_utils = require('dap.utils')
local registry = require('mason-registry')
local dap_vscode_js = require('dap-vscode-js')
local au = require('config.utils').au
local cache_vars = {}

for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
    au('FileType', {
        pattern = { language },
        desc = 'Setup ' .. language,
        callback = function()
            if not cache_vars.dap_setup then
                cache_vars.dap_setup = true
                dap_vscode_js.setup({
                    debugger_path = registry.get_package('js-debug-adapter'):get_install_path(),
                    adapters = {
                        'pwa-node',
                        'pwa-chrome',
                        'pwa-msedge',
                        'node-terminal',
                        'pwa-extensionHost',
                    },
                })
            end

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
        end,
    })
end
