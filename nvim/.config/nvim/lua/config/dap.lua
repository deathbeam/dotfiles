local fzf_lua = require("fzf-lua")
local utils = require("config.utils")
local nmap = utils.nmap
local rnmap = utils.rnmap
local nvmap = utils.rnvmap
local desc = utils.desc
local au = utils.au

desc("<leader>d", "[D]ebug")

local icons = require("config.icons")
for name, sign in pairs(icons.dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define("Dap" .. name, { text = sign[1], texthl = sign[2] or "DiagnosticInfo" })
end

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

au("VimResized", {
    desc = "DAP UI resize",
    callback = function()
        for _, win_layout in ipairs(dapui_windows.layouts) do
            win_layout:resize({ reset = true })
        end
    end
})

rnmap("<leader>d<space>", function() if dap.session() then dap.continue() end end, "[D]ebug Continue")
rnmap("<leader>dj", dap.step_over, "[D]ebug Step Over (down)")
rnmap("<leader>dk", dap.step_back, "[D]ebug Step Back (up)")
rnmap("<leader>dl", dap.step_into, "[D]ebug Step Into (right)")
rnmap("<leader>dh", dap.step_out, "[D]ebug Step Out (left)")

nmap("<leader>dx", function() dap.terminate(); dapui.close() end, "[D]ebug E[X]it")
nmap("<leader>dr", dap.restart, "[D]ebug [R]estart")
nmap("<leader>dd", function() if not dap.session() then dap.continue() end end, "[D]ebug Start")
rnmap("<leader>db", dap.toggle_breakpoint, "[D]ebug [B]reakpoint")
nmap("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "[D]ebug Conditional [B]reakpoint")
nmap("<leader>dL", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, "[D]ebug [L]og Point")
nvmap("<leader>dw", dapui.elements.watches.add, "[D]ebug [W]atch")
nvmap("<leader>de", dapui.eval, "[D]ebug [E]valuate")
nmap("<leader>du", function() dapui.toggle({ reset = true }) end, "[D]ebug [U]I")
nmap("<leader>fp", fzf_lua.dap_breakpoints, "[F]ind Break[P]oints")
