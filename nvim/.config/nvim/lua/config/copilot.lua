-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Copilot chat
require("CopilotChat").setup({})

local prompts = {
    {
        prompt = 'Explain how it works.',
        desc = '[E]explain',
        key = 'e'
    },
    {
        prompt = 'Briefly explain how selected code works then generate unit tests.',
        desc = 'Generate [T]ests',
        key = 't'
    },
    {
        prompt = 'Briefly explain how selected code works then generate documentation using comments. Make sure to document it properly if it is function or method or class.',
        desc = '[D]ocumentation',
        key = 'd'
    },
    {
        prompt = 'Find possible errors and fix them for me.',
        desc = '[F]ix',
        key = 'f'
    },
    {
        prompt = 'Optimize the code to improve performance and readablilty.',
        desc = '[O]ptimize',
        key = 'o'
    },
    {
        prompt = 'Simplify and improve readablilty',
        desc = '[S]implify',
        key = 's'
    },

}

vim.keymap.set('n', '<leader>cd', '<cmd>CopilotChatFixDiagnostic<CR>', { desc = "[C]ode Fix [D]iagnostic" })

for _, prompt in ipairs(prompts) do
    vim.keymap.set('n', string.format('<leader>a%s', prompt.key), string.format('<cmd>CopilotChat %s<CR>', prompt.prompt), { desc = "[A]I " .. prompt.desc })
    vim.keymap.set('v', string.format('<leader>a%s', prompt.key), string.format(':CopilotChatVisual %s<CR>', prompt.prompt), { desc = "[A]I " .. prompt.desc })
end
