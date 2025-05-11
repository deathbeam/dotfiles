local fzf_lua = require('fzf-lua')
local utils = require('config.utils')
local nmap = utils.nmap
local rnmap = utils.rnmap
local nvmap = utils.nvmap
local desc = utils.desc
local au = utils.au

desc('<leader>d', 'Debug')

local icons = require('config.icons')
for name, sign in pairs(icons.dap) do
    sign = type(sign) == 'table' and sign or { sign }
    vim.fn.sign_define('Dap' .. name, { text = sign[1], texthl = sign[2] or 'DiagnosticInfo' })
end

-- Debugprint
require('debugprint').setup()
local debugprint_printtag_operations = require('debugprint.printtag_operations')
nmap('<leader>dp', debugprint_printtag_operations.show_debug_prints_fzf, 'Show Debug Prints')

-- Dap
local dap = require('dap')
local widgets = require('dap.ui.widgets')
local autocompl = require('dap.ext.autocompl')
local terminal = require('config.dap.terminal')
dap.defaults.fallback.terminal_win_cmd = ':lua require("config.dap.terminal").open()'

require('nvim-dap-virtual-text').setup({})
au('FileType', {
    pattern = { 'dap-repl' },
    desc = 'Setup dap repl',
    callback = function()
        autocompl.attach()
    end,
})

-- General workflow
rnmap('<leader>dd', dap.continue, 'Debug Continue')
rnmap('<leader>dj', dap.step_over, 'Debug Step Over (down)')
rnmap('<leader>dk', dap.step_back, 'Debug Step Back (up)')
rnmap('<leader>dl', dap.step_into, 'Debug Step Into (right)')
rnmap('<leader>dh', dap.step_out, 'Debug Step Out (left)')

-- Widgets
nmap('<leader>d<space>', dap.repl.toggle, 'Debug REPL')
nmap('<leader>dc', terminal.toggle, 'Debug Console')
nmap('<leader>ds', widgets.sidebar(widgets.scopes).toggle, 'Debug Scopes')
nmap('<leader>df', widgets.sidebar(widgets.frames).toggle, 'Debug Frames')
nmap('<leader>dt', widgets.sidebar(widgets.threads).toggle, 'Debug Threads')
nvmap('<leader>de', widgets.sidebar(widgets.expression).toggle, 'Debug Expression')

-- Debugging
nmap('<leader>dx', function()
    dap.terminate()
    terminal.close()
    dap.repl.close()
end, 'Debug Exit')
nmap('<leader>dr', dap.restart, 'Debug Restart')
nmap('<leader>db', dap.toggle_breakpoint, 'Debug Breakpoint')
nmap('<leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Condition: '))
end, 'Debug Conditional Breakpoint')
nmap('<leader>dL', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log: '))
end, 'Debug Log Point')
nmap('<leader>fp', fzf_lua.dap_breakpoints, 'Find Breakpoints')
