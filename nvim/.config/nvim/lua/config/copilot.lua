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
local prompts = require('CopilotChat.config.prompts')
local select = require('CopilotChat.select')
local cutils = require('CopilotChat.utils')

local COPILOT_PLAN = [[
You are a software architect and technical planner focused on clear, actionable development plans.
]] .. prompts.COPILOT_BASE.system_prompt .. [[

When creating development plans:
- Start with a high-level overview
- Break down into concrete implementation steps
- Identify potential challenges and their solutions
- Consider architectural impacts
- Note required dependencies or prerequisites
- Estimate complexity and effort levels
- Track confidence percentage (0-100%)
- Format in markdown with clear sections

Always end with:
"Current Confidence Level: X%"
"Would you like to proceed with implementation?" (only if confidence >= 90%)
]]

chat.setup({
    model = 'gpt-4.1',
    debug = true,
    temperature = 0,
    question_header = ' ' .. icons.ui.User .. ' ',
    answer_header = ' ' .. icons.ui.Bot .. ' ',
    error_header = '> ' .. icons.diagnostics.Warn .. ' ',
    sticky = '#buffers',
    mappings = {
        reset = false,
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
        Plan = {
            prompt = 'Create or update the development plan for the selected code. Focus on architecture, implementation steps, and potential challenges.',
            system_prompt = COPILOT_PLAN,
            context = 'file:.copilot/plan.md',
            progress = function()
                return false
            end,
            callback = function(response, source)
                chat.chat:append('Plan updated successfully!', source.winnr)
                local plan_file = source.cwd() .. '/.copilot/plan.md'
                local dir = vim.fn.fnamemodify(plan_file, ':h')
                vim.fn.mkdir(dir, 'p')
                local file = io.open(plan_file, 'w')
                if file then
                    file:write(response)
                    file:close()
                end
            end,
        },
    },
    contexts = {
        vectorspace = {
            description = 'Semantic search through workspace using vector embeddings. Find relevant code with natural language queries.',

            schema = {
                type = 'object',
                required = { 'query' },
                properties = {
                    query = {
                        type = 'string',
                        description = 'Natural language query to find relevant code.',
                    },
                    max = {
                        type = 'integer',
                        description = 'Maximum number of results to return.',
                        default = 10,
                    },
                },
            },

            resolve = function(input, source, prompt)
                local embeddings = cutils.curl_post('http://localhost:8000/query', {
                    json_request = true,
                    json_response = true,
                    body = {
                        dir = source.cwd(),
                        text = input.query or prompt,
                        max = input.max,
                    },
                }).body

                cutils.schedule_main()
                return vim.iter(embeddings)
                    :map(function(embedding)
                        embedding.filetype = cutils.filetype(embedding.filename)
                        return embedding
                    end)
                    :filter(function(embedding)
                        return embedding.filetype
                    end)
                    :totable()
            end,
        },
    },
    providers = {
        github_models = {
            disabled = true,
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
local mcp = require('mcphub')
mcp.on({ 'servers_updated', 'tool_list_changed', 'resource_list_changed' }, function()
    if not chat.config.functions then
        return
    end

    local hub = mcp.get_hub_instance()
    if not hub then
        return
    end

    local async = require('plenary.async')
    local call_tool = async.wrap(function(server, tool, input, callback)
        hub:call_tool(server, tool, input, {
            callback = function(res, err)
                callback(res, err)
            end,
        })
    end, 4)

    local access_resource = async.wrap(function(server, uri, callback)
        hub:access_resource(server, uri, {
            callback = function(res, err)
                callback(res, err)
            end,
        })
    end, 3)

    local resources = hub:get_resources()
    local resource_templates = hub:get_resource_templates()
    vim.list_extend(resources, resource_templates)
    for _, resource in ipairs(resources) do
        local name = resource.name:lower():gsub(' ', '_'):gsub(':', '')
        chat.config.functions[name] = {
            uri = resource.uri or resource.uriTemplate,
            description = type(resource.description) == 'string' and resource.description or '',
            resolve = function()
                local res, err = access_resource(resource.server_name, resource.uri)
                if err then
                    error(err)
                end

                res = res or {}
                local result = res.result or {}
                local content = result.contents or {}
                local out = {}

                for _, message in ipairs(content) do
                    if message.text then
                        table.insert(out, {
                            uri = message.uri,
                            data = message.text,
                            mimetype = message.mimeType,
                        })
                    end
                end

                return out
            end,
        }
    end

    local tools = hub:get_tools()
    for _, tool in ipairs(tools) do
        chat.config.functions[tool.name] = {
            group = tool.server_name,
            description = tool.description,
            schema = tool.inputSchema,
            resolve = function(input)
                local res, err = call_tool(tool.server_name, tool.name, input)
                if err then
                    error(err)
                end

                res = res or {}
                local result = res.result or {}
                local content = result.content or {}
                local out = {}

                for _, message in ipairs(content) do
                    if message.type == 'text' then
                        table.insert(out, {
                            data = message.text,
                        })
                    elseif message.type == 'resource' and message.resource and message.resource.text then
                        table.insert(out, {
                            uri = message.resource.uri,
                            data = message.resource.text,
                            mimetype = message.resource.mimeType,
                        })
                    end
                end

                return out
            end,
        }
    end
end)
mcp.setup()
