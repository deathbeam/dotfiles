local cfg = require('slopcode.config')
cfg.model = 'crofai/glm-5.1-precision'
cfg.hide_reasoning = true

local chat = require('slopcode.chat')
vim.keymap.set('n', '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set('n', '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set('n', '<leader>as', chat.abort, { desc = 'AI Stop' })
vim.keymap.set('n', '<leader>am', chat.model, { desc = 'AI Models' })
vim.keymap.set('n', '<leader>ac', function()
    chat.open()
    chat.send(
        '@.git/COMMIT_EDITMSG Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.'
    )
end, { desc = 'AI Commit' })

-- Debugging
local events = {}
require('slopcode.loop').subscribe(function(event)
    events[#events + 1] = event
end)

vim.keymap.set('n', '<leader>ade', function()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = 'json'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].undolevels = -1
    vim.api.nvim_open_win(buf, true, { split = 'below' })

    local text = vim.json.encode(events, { indent = '  ' })
    local lines = vim.split(text, '\n', { plain = true })

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
end, { desc = 'AI Debug Events' })

vim.keymap.set('n', '<leader>adp', function()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = 'markdown'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].undolevels = -1
    vim.api.nvim_open_win(buf, true, { split = 'below' })

    local text = require('async').run(require('slopcode.prompt').build):wait()
    local lines = vim.split(text, '\n', { plain = true })

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
end, { desc = 'AI Debug Prompt' })

vim.keymap.set('n', '<leader>adc', function()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = 'lua'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].undolevels = -1
    vim.api.nvim_open_win(buf, true, { split = 'below' })

    local text = vim.inspect(require('async').run(require('slopcode.catalog').build):wait())
    local lines = vim.split(text, '\n', { plain = true })

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
end, { desc = 'AI Debug Catalog' })
