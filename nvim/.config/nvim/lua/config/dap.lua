local nmap = require('config/utils').nmap
local fzf_lua = require('fzf-lua')

require("which-key").register {
    ['<leader>d'] = { name = "[D]ebug", _ = 'which_key_ignore' },
}

local dap = require("dap")
local dapui = require("dapui")
require("nvim-dap-virtual-text").setup()
dapui.setup { controls = { enabled = false } }
dap.listeners.before.attach.dapui_config = dapui.open
dap.listeners.before.launch.dapui_config = dapui.open
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close

nmap('<leader>dx', function()
    dap.disconnect({ terminateDebuggee = true })
    dap.close()
    dapui.close()
end, '[D]ebug E[X]it')
nmap('<leader>dr', dap.restart, '[D]ebug [R]estart')
nmap('<leader>du', dapui.toggle, '[D]ebug [U]I Toggle')
nmap('<leader>dd', dap.continue, '[D]ebug Continue')
nmap('<leader>dj', dap.step_over, '[D]ebug Step Over (down)')
nmap('<leader>dk', dap.step_back, '[D]ebug Step Back (up)')
nmap('<leader>dl', dap.step_into, '[D]ebug Step Into (right)')
nmap('<leader>dh', dap.step_out, '[D]ebug Step Out (left)')
nmap('<leader>db', dap.toggle_breakpoint, '[D]ebug [B]reakpoint')
nmap('<leader>dB', function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, '[D]ebug Conditional [B]reakpoint')
nmap('<leader>fp', fzf_lua.dap_breakpoints, '[F]ind Break[P]oints')
