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

require('plenary.async').void(function()
    local config = require('CopilotChat.config')
    local resp, err = require("CopilotChat.utils").curl_get("https://models.dev/api.json", { json_response = true })
    if err then
        return
    end

    for pid, p in pairs(resp.body) do
        if p.api then
            config.providers[pid] = {
                prepare_input = config.providers.copilot.prepare_input,
                prepare_output = config.providers.copilot.prepare_output,

                get_headers = function()
                    local api_key_name = p.env and p.env[1] or (pid:upper() .. "_API_KEY")
                    local api_key = assert(os.getenv(api_key_name), api_key_name .. ' env not set')
                    return {
                        Authorization = 'Bearer ' .. api_key,
                        ['Content-Type'] = 'application/json',
                    }
                end,

                get_models = function()
                    return vim.tbl_map(function(m)
                        return {
                            id = m.id,
                            name = m.name,
                            max_input_tokens = m.limit and m.limit.context or 0,
                            max_output_tokens = m.limit and m.limit.output or 0,
                            streaming = true,
                            tools = m.tool_call
                        }
                    end, vim.tbl_values(p.models or {}))
                end,

                get_url = function()
                    return p.api .. "/chat/completions"
                end,
            }
        end
    end
end)()
