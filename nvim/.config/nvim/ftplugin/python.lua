local dap = require('dap')
local registry = require('mason-registry')

dap.adapters.python = function(callback, config)
  if config.request == 'launch' then
    callback({
      type = 'executable',
      command = registry.get_package('debugpy'):get_install_path() .. '/venv/bin/python',
      args = { '-m', 'debugpy.adapter' },
    })
  else
    callback({
      type = 'server',
      port = config.connect.port,
      host = config.connect.host,
      options = {
        source_filetype = 'python'
      }
    })
  end
end

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch a debugging session',
    program = "${file}",
    pythonPath = 'python'
  },
  {
    type = 'python',
    request = 'attach',
    name = 'Attach a debugging session',
    connect = function()
        local host = vim.fn.input('Host [127.0.0.1]: ')
        host = host ~= '' and host or '127.0.0.1'
        local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
        return { host = host, port = port }
    end,
  },
}
