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
        local response, err =
            require('CopilotChat.utils.curl').get('https://generativelanguage.googleapis.com/v1beta/openai/models', {
                headers = headers,
                json_response = true,
            })

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
    description = 'Show all globally defined keymaps',
    uri = 'neovim://keymaps',
    resolve = function()
        local maps = vim.api.nvim_get_keymap('n')
        local lines = {}

        for _, map in ipairs(maps) do
            table.insert(lines, string.format('%-10s -> %s [%s]', map.lhs, map.rhs or '', map.desc or ''))
        end

        return {
            {
                data = table.concat(lines, '\n'),
                uri = 'neovim://keymaps',
            },
        }
    end,
}
