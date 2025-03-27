local utils = require('config.utils')
local kulala = require("kulala")
kulala.setup({})

utils.desc('<leader>h', 'HTTP')

utils.nmap('<leader>ho', function()
    kulala.open()
end, 'HTTP Open')

utils.nmap('<leader>hh', function()
    kulala.run()
end, 'HTTP Run')

utils.nmap('<leader>hH', function()
    kulala.run_all()
end, 'HTTP Run All')

utils.nmap('<leader>h<space>', function()
    kulala.replay()
end, 'HTTP Replay')

utils.nmap('<leader>he', function()
    kulala.set_selected_env()
end, 'HTTP Environment')

utils.nmap(']h', function()
    kulala.jump_next()
end, 'HTTP Jump Next')

utils.nmap('[h', function()
    kulala.jump_prev()
end, 'HTTP Jump Previous')
