local dap = require('dap')

dap.adapters['local-lua'] = {
    type = 'executable',
    command = 'local-lua-dbg',
}

dap.configurations.lua = {
    {
        type = 'local-lua',
        request = 'attach',
        name = 'Attach to remote',
        connect = function()
            local host = vim.fn.input('Host [127.0.0.1]: ')
            host = host ~= '' and host or '127.0.0.1'
            local port = tonumber(vim.fn.input('Port [9966]: ')) or 9966
            return { host = host, port = port }
        end,
    }
}
