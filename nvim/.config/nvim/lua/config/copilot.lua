local utils = require('config.utils')
local icons = require('config.icons')
utils.desc('<leader>a', 'AI')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = false
vim.g.copilot_proxy_strict_ssl = false
vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Copilot chat
local chat = require('CopilotChat')
local select = require('CopilotChat.select')

chat.setup({
    model = 'gpt-4.1',
    debug = true,
    temperature = 0,
    sticky = '#buffers',
    headers = {
        user = ' ' .. icons.ui.User .. ' ',
        assistant = ' ' .. icons.ui.Bot .. ' ',
        tool = ' ' .. icons.ui.Tool .. ' ',
    },
    mappings = {
        reset = false,
        complete = {
            insert = '<Tab>'
        },
        show_diff = {
            full_diff = true,
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
            selection = select.buffer,
        }
    },
    providers = {
        github_models = {
            disabled = false,
        },
        gemini = {
            prepare_input = require('CopilotChat.config.providers').copilot.prepare_input,
            prepare_output = require('CopilotChat.config.providers').copilot.prepare_output,

            get_headers = function()
                local api_key = assert(os.getenv('GEMINI_API_KEY'), 'GEMINI_API_KEY env not set')
                return {
                    Authorization = 'Bearer ' .. api_key,
                    ['Content-Type'] = 'application/json',
                }
            end,

            get_models = function(headers)
                local response, err = require('CopilotChat.utils').curl_get(
                    'https://generativelanguage.googleapis.com/v1beta/openai/models',
                    {
                        headers = headers,
                        json_response = true,
                    }
                )

                if err then
                    error(err)
                end

                return vim.tbl_map(function(model)
                    local id = model.id:gsub('^models/', '')
                    return {
                        id = id,
                        name = id,
                        streaming = true,
                        tools = true,
                    }
                end, response.body.data)
            end,

            embed = function(inputs, headers)
                local response, err = require('CopilotChat.utils').curl_post(
                    'https://generativelanguage.googleapis.com/v1beta/openai/embeddings',
                    {
                        headers = headers,
                        json_request = true,
                        json_response = true,
                        body = {
                            input = inputs,
                            model = 'text-embedding-004',
                        },
                    }
                )

                if err then
                    error(err)
                end

                return response.body.data
            end,

            get_url = function()
                return 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'
            end,
        },
    },
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

-- MCP hub
require('mcphub').setup({
    extensions = {
        copilotchat = {
            enabled = true,
            convert_tools_to_functions = true,
            convert_resources_to_functions = true,
            add_mcp_prefix = false,
        },
    }
})
