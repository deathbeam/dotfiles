local utils = require('config.utils')
local icons = require('config.icons')

-- Copilot autosuggestions
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_hide_during_completion = false
-- vim.g.copilot_proxy_strict_ssl = false
-- vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Copilot chat
local chat = require('CopilotChat')
chat.setup({
    debug = false,
    temperature = 0,
    sticky = {
        '#buffer:listed',
        '#selection',
        '#gitdiff'
    },
    diff = 'block',
    chat_autocomplete = false,
    auto_fold = true,
    headers = {
        user = icons.ui.User,
        assistant = icons.ui.Bot,
        tool = icons.ui.Tool,
    },
    mappings = {
        reset = false,
        complete = {
            insert = '<Tab>',
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
    providers = {
        github_models = {
            disabled = true,
        },
    },
})

-- Setup extensions
require('config.copilot_extensions')

-- Setup buffer
utils.au('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
    end,
})

-- Setup keymaps
vim.keymap.set({ 'n' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'v' }, '<leader>aa', chat.open, { desc = 'AI Open' })
vim.keymap.set({ 'n' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set({ 'n' }, '<leader>as', chat.stop, { desc = 'AI Stop' })
vim.keymap.set({ 'n' }, '<leader>am', chat.select_model, { desc = 'AI Models' })
vim.keymap.set({ 'n', 'v' }, '<leader>ap', chat.select_prompt, { desc = 'AI Prompts' })
vim.keymap.set({ 'n', 'v' }, '<leader>aq', function()
    vim.ui.input({
        prompt = 'AI Question> ',
    }, function(input)
        if input ~= '' then
            chat.ask(input)
        end
    end)
end, { desc = 'AI Question' })
