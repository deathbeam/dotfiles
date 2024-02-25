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

-- Copilot chat
require('CopilotChat').setup({
    show_help = 'no',
    clear_chat_on_new_prompt = 'yes',
})

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

vim.keymap.set(
    'n',
    '<leader>cd',
    '<cmd>CopilotChatFixDiagnostic<CR>',
    { desc = 'Code Fix Diagnostic' }
)

vim.keymap.set({ 'n', 'v' }, '<leader>aa', ':CopilotChatInPlace<CR>', { desc = 'AI Chat' })

for _, prompt in ipairs(prompts) do
    vim.keymap.set(
        { 'n', 'v' },
        string.format('<leader>a%s', prompt.key),
        string.format(':CopilotChatVisual %s<CR>', prompt.prompt),
        { desc = 'AI ' .. prompt.desc }
    )
end
