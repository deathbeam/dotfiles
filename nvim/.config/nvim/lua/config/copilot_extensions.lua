require('CopilotChat.config').functions.plan = {
    description = [[
Store the provided markdown-formatted development plan as a file resource (.copilot/plan.md).
Returns the plan file resource for future reference and actions.

This plan can be updated iteratively as the project evolves.
Use the latest saved plan as a reference for all future development actions and tool calls.
]],
    schema = {
        type = "object",
        properties = {
            plan = { type = "string", description = "The markdown-formatted development plan to save or update." },
        },
        required = { "plan" },
    },
    resolve = function(input, source)
        require('CopilotChat.utils').schedule_main()
        local plan_file = source.cwd() .. '/.copilot/plan.md'
        local dir = vim.fn.fnamemodify(plan_file, ':h')
        vim.fn.mkdir(dir, 'p')
        local file = io.open(plan_file, 'w')
        if file then
            file:write(input.plan)
            file:close()
        end
        return {
            {
                uri = 'file://' .. plan_file,
                name = '.copilot/plan.md',
                mimetype = 'text/markdown',
                data = input.plan,
            }
        }
    end,
}

require('CopilotChat.config').prompts.Plan = {
    system_prompt = [[
You are a software architect and technical planner focused on clear, actionable development plans.

When creating development plans:
- ALWAYS use plan tool to store and retrieve current plan after each step
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

{BASE_INSTRUCTIONS}
]],
    tools = {
        "copilot", "plan"
    },
}

require('CopilotChat.config').providers.openwebui = {
    prepare_input = require('CopilotChat.config.providers').copilot.prepare_input,
    prepare_output = require('CopilotChat.config.providers').copilot.prepare_output,

    get_headers = function()
        local api_key = assert(os.getenv('OPENWEBUI_API_KEY'), 'OPENWEBUI_API_KEY env not set')
        return {
            Authorization = 'Bearer ' .. api_key,
            ['Content-Type'] = 'application/json',
        }
    end,

    get_models = function(headers)
        local response, err = require('CopilotChat.utils').curl_get('http://localhost:3000/api/models', {
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

    get_url = function()
        return 'http://localhost:3000/api/chat/completions'
    end,
}

require('CopilotChat.config').providers.gemini = {
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

    get_url = function()
        return 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'
    end,
}

require('CopilotChat.config').functions.keymaps = {
    description = "Show all globally defined keymaps",
    uri = "neovim://keymaps",
    resolve = function()
        local maps = vim.api.nvim_get_keymap("n")
        local lines = {}

        for _, map in ipairs(maps) do
            table.insert(lines, string.format("%-10s -> %s [%s]", map.lhs, map.rhs or "", map.desc or ""))
        end

        return {
            {
                data = table.concat(lines, "\n"),
                uri = "neovim://keymaps"
            }
        }
    end
}

require('CopilotChat.config').functions.vectorspace = {
    description = 'Semantic search through workspace using vector embeddings. Find relevant code with natural language queries.',
    schema = {
        type = 'object',
        properties = {
            query = {
                type = 'string',
                description = 'The search query to find relevant code snippets.',
            },
            max = {
                type = 'integer',
                description = 'Maximum number of results to return.',
                default = 10,
            },
        },
        required = { 'query' },
    },
    resolve = function(input, source)
        local utils = require('CopilotChat.utils')
        local embeddings = utils.curl_post('http://localhost:8000/query', {
            json_request = true,
            json_response = true,
            body = {
                dir = source.cwd(),
                text = input.query,
                max = tonumber(input.max or 10),
            }
        }).body

        utils.schedule_main()
        return vim.iter(embeddings)
            :map(function(embedding)
                embedding.filetype = utils.filetype(embedding.filename)
                return embedding
            end)
            :filter(function(embedding)
                return embedding.filetype
            end)
            :map(function(embedding)
                return {
                    uri = 'file://' .. embedding.filename,
                    name = embedding.filename,
                    mimetype = utils.filetype_to_mimetype(utils.filetype(embedding.filename)),
                    data = embedding.text,
                }
            end)
            :totable()
    end,
}
