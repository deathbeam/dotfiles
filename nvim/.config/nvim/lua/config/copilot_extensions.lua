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
