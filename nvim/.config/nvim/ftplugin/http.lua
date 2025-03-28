local utils = require('config.utils')
local http = require("config.http")

utils.desc('<leader>h', 'HTTP')

utils.nmap('<leader>ho', function()
    http.toggle()
end, 'HTTP Toggle')

utils.nmap('<leader>hh', function()
    http.run()
end, 'HTTP Run')

utils.nmap('<leader>hH', function()
    http.run_all()
end, 'HTTP Run All')

utils.nmap('<leader>he', function()
    http.select_env()
end, 'HTTP Environment')
