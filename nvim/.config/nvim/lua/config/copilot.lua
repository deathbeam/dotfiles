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
})

local prompts = {
    {
        prompt = 'Briefly explain how selected code works.',
        desc = 'Explain',
        key = 'e',
    },
    {
        prompt = 'Generate unit tests for selected code.',
        desc = 'Generate Tests',
        key = 't',
    },
    {
        prompt = 'Generate documentation for selected code using comments. Make sure to use proper documentation format for language of the code block. Also document paramater and return types.',
        desc = 'Documentation',
        key = 'd',
    },
    {
        prompt = 'Find possible errors and fix them for me.',
        desc = 'Fix',
        key = 'f',
    },
    {
        prompt = 'Optimize the code to improve performance and readablilty.',
        desc = 'Optimize',
        key = 'o',
    },
    {
        prompt = 'Simplify the code and improve readablilty',
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
        'n',
        string.format('<leader>a%s', prompt.key),
        string.format('<cmd>CopilotChat %s<CR>', prompt.prompt),
        { desc = 'AI ' .. prompt.desc }
    )
    vim.keymap.set(
        'v',
        string.format('<leader>a%s', prompt.key),
        string.format(':CopilotChatVisual %s<CR>', prompt.prompt),
        { desc = 'AI ' .. prompt.desc }
    )
end
