local dap = require("dap")
local dap_utils = require("dap.utils")
local registry = require("mason-registry")
local cache_vars = {}

local function js_setup(language)
    if not cache_vars.dap_setup then
        cache_vars.dap_setup = true
        require("dap-vscode-js").setup({
            debugger_path = registry.get_package("js-debug-adapter"):get_install_path(),
            adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        })
    end

    dap.configurations[language] = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach process",
            processId = dap_utils.pick_process,
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-chrome",
            request = "launch",
            name = "Start Chrome with \"localhost\"",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            userDataDir = "${workspaceFolder}/.vscode/debug"
        }
    }
end

for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {language},
        desc = "Setup " .. language,
        callback = function() js_setup(language) end,
    })
end
