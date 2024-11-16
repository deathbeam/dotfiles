local utils = require('config.utils')
utils.desc('<leader>a', 'AI')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.g.copilot_proxy_strict_ssl = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

local chat = require('CopilotChat')
local actions = require('CopilotChat.actions')
local integration = require('CopilotChat.integrations.fzflua')

chat.setup({
    log_level = 'info',
    model = 'claude-3.5-sonnet',
    question_header = '   ',
    answer_header = '   ',
    error_header = '   ',
    mappings = {
        reset = {
            normal = '',
            insert = '',
        },
    },
    prompts = {
        Explain = {
            mapping = '<leader>ae',
            description = 'AI Explain',
        },
        Review = {
            mapping = '<leader>ar',
            description = 'AI Review',
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
        Commit = {
            mapping = '<leader>ac',
            description = 'AI Generate Commit',
        },
    },
})

require('render-markdown').setup({
    file_types = { 'markdown', 'copilot-chat' },
})

utils.au('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
    end,
})

vim.keymap.set({ 'n', 'v' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set({ 'n', 'v' }, '<leader>as', chat.stop, { desc = 'AI Reset' })
vim.keymap.set({ 'n', 'v' }, '<leader>ap', function()
    integration.pick(actions.prompt_actions(), {
        fzf_tmux_opts = {
            ['-d'] = '45%',
        },
    })
end, { desc = 'AI Prompts' })
vim.keymap.set({ 'n', 'v' }, '<leader>aq', function()
    local input = vim.fn.input('Question: ')
    if input ~= '' then
        chat.ask(input)
    end
end, { desc = 'AI Quick Chat' })
