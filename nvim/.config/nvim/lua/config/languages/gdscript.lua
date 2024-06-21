local dap = require('dap')
local utils = require('config.utils')
local au = utils.au

au('FileType', {
    pattern = { 'gdscript' },
    desc = 'Setup gdscript',
    callback = function()
        dap.adapters.godot = {
            type = "server",
            host = '127.0.0.1',
            port = 6006,
        }

        dap.configurations.gdscript = {
            {
                type = "godot",
                request = "launch",
                name = "Launch scene",
                project = "${workspaceFolder}",
            }
        }
    end,
})
