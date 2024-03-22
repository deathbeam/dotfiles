local utils = require('config.utils')
utils.desc('<leader>a', 'AI')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

local chat = require('CopilotChat')
local actions = require('CopilotChat.actions')
local integration = require('CopilotChat.integrations.fzflua')

local function pick(pick_actions)
    return function()
        integration.pick(pick_actions(), {
            fzf_tmux_opts = {
                ['-d'] = '45%',
            },
        })
    end
end

chat.setup({
    name = 'Copilot',
    auto_insert_mode = true,
    prompts = {
        Explain = {
            mapping = '<leader>ae',
            description = 'AI Explain',
        },
        Tests = {
            mapping = '<leader>at',
            description = 'AI Tests',
        },
        Fix = {
            mapping = '<leader>af',
            description = 'AI Fix',
        },
        Optimize = {
            mapping = '<leader>ao',
            description = 'AI Optimize',
        },
        Docs = {
            mapping = '<leader>ad',
            description = 'AI Documentation',
        },
        FixDiagnostic = {
            mapping = '<leader>ar',
            description = 'AI Fix Diagnostic',
        },
        CommitStaged = {
            mapping = '<leader>ac',
            description = 'AI Generate Commit',
        },
    },
})

vim.keymap.set({ 'n', 'v' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set({ 'n', 'v' }, '<leader>ah', pick(actions.help_actions), { desc = 'AI Help Actions' })
vim.keymap.set({ 'n', 'v' }, '<leader>ap', pick(actions.prompt_actions), { desc = 'AI Prompt Actions' })
