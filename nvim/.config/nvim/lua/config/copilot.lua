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

local chat = require('CopilotChat')
local select = require('CopilotChat.select')

chat.setup({
    disable_extra_info = false,
    window = {
        layout = 'vertical',
    },
    prompts = {
        FixDiagnostic = {
            prompt = 'Please assist with the following diagnostic issue in file:',
            selection = select.diagnostics,
            mapping = '<leader>ar',
        },
        Explain = {
            prompt = 'Explain how the selected code works.',
            mapping = '<leader>ae',
        },
        Tests = {
            prompt = 'Generate unit tests for the selected code.',
            mapping = '<leader>at',
        },
        Documentation = {
            prompt = 'Add documentation comments to the selected code.',
            mapping = '<leader>ad',
        },
        Fix = {
            prompt = 'Propose a fix for the problems in the selected code.',
            mapping = '<leader>af',
        },
        Optimize = {
            prompt = 'Optimize the selected code to improve performance and readablilty.',
            mapping = '<leader>ao',
        },
        Simplify = {
            prompt = 'Simplify the selected code and improve readablilty',
            mapping = '<leader>as',
        },
    }
})

vim.keymap.set({ 'n', 'v' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
