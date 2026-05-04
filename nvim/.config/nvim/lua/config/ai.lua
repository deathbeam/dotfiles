local cfg = require('slopcode.config')
cfg.model = 'crofai/glm-5.1-precision'
cfg.display.thinking = false

local chat = require('slopcode.chat')
vim.keymap.set('n', '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set('n', '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set('n', '<leader>as', chat.abort, { desc = 'AI Stop' })
vim.keymap.set('n', '<leader>am', chat.model, { desc = 'AI Models' })

-- Debugging
local events = {}
local loop = require('slopcode.loop')
loop.subscribe(function(event)
    events[#events + 1] = event
end)

vim.keymap.set('n', '<leader>ad', function()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = 'markdown'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].undolevels = -1
    vim.api.nvim_open_win(buf, true, { split = 'below' })

    local event_text = table.concat({
        '# Events',
        '',
        '```json',
        vim.json.encode(events, { indent = '  ' }),
        '```',
        '',
        '# System Prompt',
        '',
        '',
    }, '\n')

    local prompt = require('async').run(require('slopcode.prompt').build):wait()
    local lines = vim.split(event_text .. prompt, '\n', { plain = true })

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
end, { desc = 'AI Debug' })
