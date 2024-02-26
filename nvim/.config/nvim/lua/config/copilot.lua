local utils = require('config.utils')
utils.desc('<leader>a', 'AI')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set(
    'i',
    '<S-Tab>',
    'copilot#Accept("\\<S-Tab>")',
    { expr = true, replace_keycodes = false }
)

local chat = require('config.copilot.chat')
chat.setup()

local prompts = {
    {
        prompt = 'Explain how the selected code works.',
        desc = 'Explain',
        key = 'e',
    },
    {
        prompt = 'Generate unit tests for the selected code.',
        desc = 'Generate Tests',
        key = 't',
    },
    {
        prompt = 'Add documentation comments to the selected code.',
        desc = 'Documentation',
        key = 'd',
    },
    {
        prompt = 'Propose a fix for the problems in the selected code.',
        desc = 'Fix',
        key = 'f',
    },
    {
        prompt = 'Optimize the selected code to improve performance and readablilty.',
        desc = 'Optimize',
        key = 'o',
    },
    {
        prompt = 'Simplify the selected code and improve readablilty',
        desc = 'Simplify',
        key = 's',
    },
}

vim.keymap.set('n', '<leader>aa', function()
    chat.open()
end, { desc = 'AI Open' })

for _, prompt in ipairs(prompts) do
    vim.keymap.set({ 'n', 'v' }, string.format('<leader>a%s', prompt.key), function()
        chat.ask(prompt.prompt, { layout = 'float' })
    end, { desc = 'AI ' .. prompt.desc })
end
