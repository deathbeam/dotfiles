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
local cutils = require('CopilotChat.utils')

chat.setup({
    model = 'claude-3.5-sonnet',
    debug = true,
    question_header = ' ' .. icons.ui.User .. ' ',
    answer_header = ' ' .. icons.ui.Bot .. ' ',
    error_header = '> ' .. icons.diagnostics.Warn .. ' ',
    selection = select.visual,
    sticky = {
        '/COPILOT_GENERATE',
        '#buffers'
    },
    mappings = {
        reset = {
            normal = '',
            insert = '',
        },
        show_diff = {
            full_diff = true,
        }
    },
    prompts = {
        Yarrr = {
            system_prompt = 'You are fascinated by pirates, so please respond in pirate speak.',
        },
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
            selection = select.buffer,
        },
    },
    providers = {
        ollama = {
            disabled = true,
            embeddings = 'copilot_embeddings',

            get_headers = function()
                return {
                    ['Content-Type'] = 'application/json',
                }
            end,

            get_models = function(headers)
                local response = cutils.curl_get('http://localhost:11434/api/tags', { headers = headers })

                if not response or response.status ~= 200 then
                    error('Failed to fetch models: ' .. tostring(response and response.status))
                end

                local models = {}
                for _, model in ipairs(vim.json.decode(response.body)['models']) do
                    table.insert(models, {
                        id = model.name,
                        name = model.name,
                        version = "latest",
                        tokenizer = "o200k_base",
                    })
                end

                return models
            end,

            prepare_input = function(inputs, opts)
                return {
                    model = opts.model,
                    messages = inputs,
                    stream = true,
                }
            end,

            get_url = function()
                return 'http://localhost:11434/api/chat'
            end,
        }
    }
})

utils.au('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
    end,
})

vim.keymap.set({ 'n' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'v' }, '<leader>aa', chat.open, { desc = 'AI Open' })
vim.keymap.set({ 'n' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set({ 'n' }, '<leader>as', chat.stop, { desc = 'AI Stop' })
vim.keymap.set({ 'n' }, '<leader>am', chat.select_model, { desc = 'AI Model' })
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
end, { desc = 'AI Question' })
