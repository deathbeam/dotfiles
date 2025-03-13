local utils = require('config.utils')
local icons = require('config.icons')
utils.desc('<leader>a', 'AI')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = false
vim.g.copilot_proxy_strict_ssl = false
vim.g.copilot_integration_id = 'vscode-chat'
vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Copilot chat
local chat = require('CopilotChat')
local select = require('CopilotChat.select')
local providers = require('CopilotChat.config.providers')
local cutils = require('CopilotChat.utils')

chat.setup({
    model = 'claude-3.7-sonnet',
    references_display = 'write',
    question_header = ' ' .. icons.ui.User .. ' ',
    answer_header = ' ' .. icons.ui.Bot .. ' ',
    error_header = '> ' .. icons.diagnostics.Warn .. ' ',
    selection = select.visual,
    context = 'buffers',
    mappings = {
        reset = {
            normal = '',
            insert = '',
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
        },
    },
    contexts = {
      vectorspace = {
        description = 'Uses Vectorspace to search for semantically relevant content. Supports input (search query).',
        input = function(callback)
          vim.ui.input({
            prompt = 'Enter search query> ',
          }, callback)
        end,
        resolve = function(input, source, prompt)
          if not input or input == '' then
            input = prompt
          end
          local dir = cutils.win_cwd(source.winnr)
          return cutils.curl_post('http://localhost:8000/query', {
            json_request = true,
            json_response = true,
            body = {
              dir = dir,
              text = input,
              max = 50
            }
          }).body
        end,
      },
    },
    providers = {
        github_models = {
            disabled = true,
        },

        mistral = {
            disabled = true,
            prepare_input = providers.copilot.prepare_input,
            prepare_output = providers.copilot.prepare_output,

            get_headers = function()
                local api_key = os.getenv('MISTRAL_API_KEY')
                if not api_key then
                    error('MISTRAL_API_KEY environment variable not set')
                end

                return {
                    Authorization = 'Bearer ' .. api_key,
                    ['Content-Type'] = 'application/json',
                }
            end,

            get_models = function(headers)
                local response, err = cutils.curl_get('https://api.mistral.ai/v1/models', {
                    headers = headers,
                    json_response = true,
                })

                if err then
                    error(err)
                end

                return vim.iter(response.body.data)
                    :filter(function(model)
                        return model.capabilities.completion_chat
                    end)
                    :map(function(model)
                        return {
                            id = model.id,
                            name = model.id,
                        }
                    end)
                    :totable()
            end,

            embed = function(inputs, headers)
                local response, err = cutils.curl_post('https://api.mistral.ai/v1/embeddings', {
                    headers = headers,
                    json_request = true,
                    json_response = true,
                    body = {
                        model = 'mistral-embed',
                        input = inputs,
                    },
                })

                if err then
                    error(err)
                end

                return response.body.data
            end,

            get_url = function()
                return 'https://api.mistral.ai/v1/chat/completions'
            end,
        },

        ollama = {
            disabled = true,
            prepare_input = providers.copilot.prepare_input,
            prepare_output = providers.copilot.prepare_output,

            get_models = function(headers)
                local response, err = cutils.curl_get('http://localhost:11434/v1/models', {
                    headers = headers,
                    json_response = true,
                })

                if err then
                    error(err)
                end

                return vim.tbl_map(function(model)
                    return {
                        id = model.id,
                        name = model.id,
                    }
                end, response.body.data)
            end,

            embed = function(inputs, headers)
                local response, err = cutils.curl_post('http://localhost:11434/v1/embeddings', {
                    headers = headers,
                    json_request = true,
                    json_response = true,
                    body = {
                        input = inputs,
                        model = 'all-minilm',
                    },
                })

                if err then
                    error(err)
                end

                return response.body.data
            end,

            get_url = function()
                return 'http://localhost:11434/v1/chat/completions'
            end,
        },

        lmstudio = {
            disabled = true,
            prepare_input = providers.copilot.prepare_input,
            prepare_output = providers.copilot.prepare_output,

            get_models = function(headers)
                local response, err = cutils.curl_get('http://localhost:1234/v1/models', {
                    headers = headers,
                    json_response = true,
                })

                if err then
                    error(err)
                end

                return vim.tbl_map(function(model)
                    return {
                        id = model.id,
                        name = model.id,
                    }
                end, response.body.data)
            end,

            embed = function(inputs, headers)
                local response, err = cutils.curl_post('http://localhost:1234/v1/embeddings', {
                    headers = headers,
                    json_request = true,
                    json_response = true,
                    body = {
                        dimensions = 512,
                        input = inputs,
                        model = 'text-embedding-nomic-embed-text-v1.5',
                    },
                })

                if err then
                    error(err)
                end

                return response.body.data
            end,

            get_url = function()
                return 'http://localhost:1234/v1/chat/completions'
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
vim.keymap.set({ 'n' }, '<leader>ag', chat.select_agent, { desc = 'AI Agents' })
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
