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
local actions = require('CopilotChat.actions')
local integration = require('CopilotChat.integrations.fzflua')

local function pick(pick_actions)
    return function()
        integration.pick(pick_actions(), {}, {
            fzf_tmux_opts = {
                ['-d'] = '45%',
            },
        })
    end
end

chat.setup({
    name = 'Copilot',
    window = {
        layout = 'horizontal',
    },
    prompts = {
        FixDiagnostic = {
            mapping = '<leader>ar',
            description = 'AI Fix Diagnostic',
        },
        CommitStaged = {
            mapping = '<leader>ac',
            description = 'AI Generate Commit',
        },
        Explain = {
            prompt = '/COPILOT_EXPLAIN /USER_EXPLAIN',
            mapping = '<leader>ae',
            description = 'AI Explain',
        },
        Tests = {
            prompt = '/COPILOT_TESTS /USER_TESTS',
            mapping = '<leader>at',
            description = 'AI Tests',
        },
        Documentation = {
            prompt = '/COPILOT_DEVELOPER /USER_DOCS',
            mapping = '<leader>ad',
            description = 'AI Documentation',
        },
        Fix = {
            prompt = '/COPILOT_DEVELOPER /USER_FIX',
            mapping = '<leader>af',
            description = 'AI Fix',
        },
        Optimize = {
            prompt = '/COPILOT_DEVELOPER Optimize the selected code to improve performance and readablilty.',
            mapping = '<leader>ao',
            description = 'AI Optimize',
        },
        Simplify = {
            prompt = '/COPILOT_DEVELOPER Simplify the selected code and improve readablilty',
            mapping = '<leader>as',
            description = 'AI Simplify',
        },
    },
})

vim.keymap.set({ 'n', 'v' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set({ 'n', 'v' }, '<leader>ah', pick(actions.help_actions), { desc = 'AI Help Actions' })
vim.keymap.set(
    { 'n', 'v' },
    '<leader>ap',
    pick(actions.prompt_actions),
    { desc = 'AI Prompt Actions' }
)
