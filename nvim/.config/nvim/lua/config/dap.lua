local nmap = require('config/utils').nmap
local nvmap = require('config/utils').nvmap
local desc = require('config/utils').desc
local fzf_lua = require('fzf-lua')

desc('<leader>d', '[D]ebug')

local dap = require("dap")
local dapui = require("dapui")
local dapui_windows = require("dapui.windows")
require("nvim-dap-virtual-text").setup()
dapui.setup {
    controls = {
        enabled = false
    },
    layouts = {
        {
            elements = {
                "scopes",
                "breakpoints",
                "stacks",
                "watches"
            },
            position = "left",
            size = 0.25
        },
        {
            elements = {
                "console",
                "repl"
            },
            position = "bottom",
            size = 0.25
        }
    },
}

dap.listeners.before.attach.dapui_config = function() dapui.open({ reset = true }) end
dap.listeners.before.launch.dapui_config = function() dapui.open({ reset = true }) end
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close

vim.api.nvim_create_autocmd('VimResized', {
    desc = 'DAP UI resize',
    callback = function()
        for _, win_layout in ipairs(dapui_windows.layouts) do
            win_layout:resize({ reset = true })
        end
    end
})

nmap('<leader>dx', function()
    dap.disconnect({ terminateDebuggee = true })
    dap.close()
    dapui.close()
end, '[D]ebug E[X]it')
nmap('<leader>dr', dap.restart, '[D]ebug [R]estart')
nmap('<leader>dd', dap.continue, '[D]ebug Continue')
nmap('<leader>dj', dap.step_over, '[D]ebug Step Over (down)')
nmap('<leader>dk', dap.step_back, '[D]ebug Step Back (up)')
nmap('<leader>dl', dap.step_into, '[D]ebug Step Into (right)')
nmap('<leader>dh', dap.step_out, '[D]ebug Step Out (left)')
nmap('<leader>db', dap.toggle_breakpoint, '[D]ebug [B]reakpoint')
nmap('<leader>dB', function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, '[D]ebug Conditional [B]reakpoint')
nmap('<leader>du', function() dapui.toggle({ reset = true }) end, '[D]ebug [U]I')
nmap('<leader>dw', dapui.elements.watches.add, '[D]ebug [W]atch')
nvmap('<leader>de', dapui.eval, '[D]ebug [E]valuate')
nmap('<leader>fp', fzf_lua.dap_breakpoints, '[F]ind Break[P]oints')
