local utils = require('config.utils')
local icons = require('config.icons')
utils.desc('<leader>a', 'AI')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.g.copilot_proxy_strict_ssl = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Copilot chat
local chat = require('CopilotChat')
local actions = require('CopilotChat.actions')
local select = require('CopilotChat.select')
local integration = require('CopilotChat.integrations.fzflua')

chat.setup({
    log_level = 'debug',
    model = 'claude-3.5-sonnet',
    question_header = ' ' .. icons.ui.User .. ' ',
    answer_header = ' ' .. icons.ui.Bot .. ' ',
    error_header = ' ' .. icons.diagnostics.Warn .. ' ',
    context = 'buffer',
    selection = select.visual,
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
    vim.ui.input({
        prompt = 'AI Question> ',
    }, function(input)
        if input and input ~= '' then
            chat.ask(input)
        end
    end)
end, { desc = 'AI Quick Chat' })
