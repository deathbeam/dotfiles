local cfg = require('slopcode.config')
cfg.model = 'crofai/glm-5.1-precision'
cfg.display.thinking = false

local chat = require('slopcode.chat')
vim.keymap.set('n', '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set('n', '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set('n', '<leader>as', chat.abort, { desc = 'AI Stop' })
vim.keymap.set('n', '<leader>am', chat.model, { desc = 'AI Models' })
