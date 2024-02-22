local fzf_lua = require('fzf-lua')
local utils = require('config.utils')
local nmap = utils.nmap
local rnmap = utils.rnmap
local nvmap = utils.rnvmap
local desc = utils.desc
local au = utils.au

desc('<leader>d', 'Debug')

local icons = require('config.icons')
for name, sign in pairs(icons.dap) do
    sign = type(sign) == 'table' and sign or { sign }
    vim.fn.sign_define('Dap' .. name, { text = sign[1], texthl = sign[2] or 'DiagnosticInfo' })
end

local dap = require('dap')
local dapui = require('dapui')
local dapui_windows = require('dapui.windows')
require('nvim-dap-virtual-text').setup()
dapui.setup({
    controls = {
        enabled = false,
    },
    layouts = {
        {
            elements = {
                'scopes',
                'stacks',
                'watches',
                'repl',
            },
            position = 'left',
            size = 0.25,
        },
        {
            elements = {
                'console',
            },
            position = 'bottom',
            size = 0.25,
        },
    },
})

dap.listeners.before.attach.dapui_config = function()
    dapui.open({ reset = true })
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open({ reset = true })
end

au('VimResized', {
    desc = 'DAP UI resize',
    callback = function()
        for _, win_layout in ipairs(dapui_windows.layouts) do
            win_layout:resize({ reset = true })
        end
    end,
})

rnmap('<leader>d<space>', function()
    if dap.session() then
        dap.continue()
    end
end, 'Debug Continue')
rnmap('<leader>dj', dap.step_over, 'Debug Step Over (down)')
rnmap('<leader>dk', dap.step_back, 'Debug Step Back (up)')
rnmap('<leader>dl', dap.step_into, 'Debug Step Into (right)')
rnmap('<leader>dh', dap.step_out, 'Debug Step Out (left)')

nmap('<leader>dd', fzf_lua.dap_configurations, 'Debug Configurations')
nmap('<leader>dx', function()
    dap.terminate()
    dapui.close()
end, 'Debug Exit')
nmap('<leader>dr', dap.restart, 'Debug Restart')
rnmap('<leader>db', dap.toggle_breakpoint, 'Debug Breakpoint')
nmap('<leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Condition: '))
end, 'Debug Conditional Breakpoint')
nmap('<leader>dL', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log message: '))
end, 'Debug Log Point')
nvmap('<leader>dw', dapui.elements.watches.add, 'Debug Watch')
nvmap('<leader>de', dapui.eval, 'Debug Evaluate')
nmap('<leader>du', function()
    dapui.toggle({ reset = true })
end, 'Debug UI')
nmap('<leader>fp', fzf_lua.dap_breakpoints, 'Find Breakpoints')
