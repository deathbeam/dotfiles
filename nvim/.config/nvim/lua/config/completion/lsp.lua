local M = {}

local state = {
    ns = nil,
    signature_window = nil,
    skip_next = false,
    debounce_cache = {}
}

local methods = vim.lsp.protocol.Methods

local function debounce(name, ms, func)
    local entry = state.debounce_cache[name]
    if entry then
        entry.timer:stop()
        if entry.cancel then
            entry.cancel()
            entry.cancel = nil
        end
    else
        entry = {
            timer = vim.uv.new_timer(),
            cancel = nil
        }
        state.debounce_cache[name] = entry
    end

    entry.timer:start(ms, 0, vim.schedule_wrap(function()
        entry.cancel = func()
    end))
end

local function handle(client, line, col, handler)
    return function (err, result, ctx)
        if err or not result or not vim.api.nvim_buf_is_valid(ctx.bufnr) or not vim.fn.mode() == 'i' then
            return
        end

        handler(client, line, col, result, ctx)
    end
end

local function request(client, method, params, handler, bufnr)
    local ok, cancel_id = client.request(method, params, handler, bufnr)
    if not ok then
        return
    end
    return function()
        client.cancel_request(cancel_id)
    end
end

local function with_client(callback)
    return function(args)
        local bufnr = args.buf
        local clients = vim.lsp.get_clients({ bufnr, method = methods.textDocument_completion })
        if #clients == 0 then
            return
        end

        local client = clients[1]
        if client then
            callback(client, bufnr)
        end
    end
end

local function complete_done(client, bufnr)
    local item = vim.tbl_get(vim.v, 'completed_item', 'user_data', 'nvim', 'lsp', 'completion_item')
    if not item then
        return
    end

    if #(item.additionalTextEdits or {}) == 0 then
        debounce('textEdits', M.config.debounce_delay, function()
            return request(client, methods.completionItem_resolve, item, function(_, result)
                if #(result.additionalTextEdits or {}) ~= 0 then
                    vim.lsp.util.apply_text_edits(result.additionalTextEdits, bufnr, client.offset_encoding)
                end
            end, bufnr)
        end)
    else
        vim.lsp.util.apply_text_edits(item.additionalTextEdits, bufnr, client.offset_encoding)
    end

    state.skip_next = true
end

local function complete_changed(client, bufnr)
    local item = vim.tbl_get(vim.v.event, 'completed_item', 'user_data', 'nvim', 'lsp', 'completion_item')
    if not item then
        return
    end

    -- FIXME: Sometimes I do not receive updated complete_info (for example requests.get, 
    -- I get index 19 instead of 0 as its only match, when I press backspace it updates to 0)
    local data = vim.fn.complete_info()
    local selected = data.selected

    debounce('info', M.config.debounce_delay, function()
        return request(client, methods.completionItem_resolve, item, function(_, result)
            local info = vim.fn.complete_info()

            -- FIXME: Preview popup do not auto resizes to fit new content so have to reset it like this
            if info.preview_winid and vim.api.nvim_win_is_valid(info.preview_winid) then
                vim.api.nvim_win_close(info.preview_winid, true)
            end

            if
                not result
                or not info.items
                or not info.selected
                or not info.selected == selected
            then
                return
            end

            local value = vim.tbl_get(result, 'documentation', 'value')
            if value then
                local wininfo = vim.api.nvim_complete_set(selected, { info = value })
                if wininfo.winid and wininfo.bufnr then
                    vim.wo[wininfo.winid].conceallevel = 2
                    vim.wo[wininfo.winid].concealcursor = 'niv'
                    vim.bo[wininfo.bufnr].syntax = 'markdown'
                end
            end
        end, bufnr)
    end)
end

local function completion_handler(client, line, col, result, ctx)
    local cmp_start = vim.fn.match(line:sub(1, col), '\\k*$')
    local prefix = line:sub(cmp_start + 1, col)
    local items = vim.lsp._completion._lsp_to_complete_items(result, prefix)
    items = vim.tbl_filter(function (item) return item.kind ~= "Snippet" end, items)
    vim.schedule(function()
        if vim.fn.mode() == 'i' then
            vim.fn.complete(cmp_start + 1, items)
        end
    end)
end

local function close_signature_window()
    if state.signature_window and vim.api.nvim_win_is_valid(state.signature_window) then
        vim.api.nvim_win_close(state.signature_window, true)
        state.signature_window = nil
    end
end

local function signature_handler(client, line, col, result, ctx)
    local triggers = client.server_capabilities.signatureHelpProvider.triggerCharacters
    local ft = vim.bo[ctx.bufnr].filetype
    local lines, hl = vim.lsp.util.convert_signature_help_to_markdown_lines(result, ft, triggers)
    if not lines or vim.tbl_isempty(lines) then
        close_signature_window()
        return
    end
    lines = { unpack(lines, 1, 3) }

    local fbuf, fwin = vim.lsp.util.open_floating_preview(lines, 'markdown', {
        focusable = false,
        close_events = { 'CursorMoved', 'BufLeave', 'BufWinLeave' },
        border = M.config.window.border,
    })

    if hl then
        vim.api.nvim_buf_add_highlight(fbuf, state.ns, 'PmenuSel', vim.startswith(lines[1], '```') and 1 or 0, unpack(hl))
    end

    state.signature_window = fwin
end

local function text_changed(client, bufnr)
    -- We do not want to trigger completion again if we just accepted a completion
    if state.skip_next then
        state.skip_next = false
        return
    end

    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 or #line == 0 then
        return
    end

    local before_line = line:sub(1, col)
    local char = line:sub(col, col)
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local sig_found = false

    -- Try to find signature help trigger character in current line
    for _, c in ipairs(vim.tbl_get(client.server_capabilities, 'signatureHelpProvider', 'triggerCharacters') or {}) do
        if string.find(before_line, "[" .. c .. "]") then
            params.context = {
                triggerKind = vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter,
                triggerCharacter = c
            }

            debounce('signature', M.config.debounce_delay, function()
                return request(client, methods.textDocument_signatureHelp, params, handle(client, line, col, signature_handler), bufnr)
            end)

            sig_found = true
            break
        end
    end

    if not sig_found then
        close_signature_window()
    end

    -- Check if we are triggering completion automatically or on trigger character
    if vim.tbl_contains(client.server_capabilities.completionProvider.triggerCharacters or {}, char) then
        params.context = {
            triggerKind = vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter,
            triggerCharacter = char
        }
    else
        params.context = {
            triggerKind = vim.lsp.protocol.CompletionTriggerKind.Invoked,
            triggerCharacter = ''
        }
    end

    debounce('completion', M.config.debounce_delay, function()
        return request(client, methods.textDocument_completion, params, handle(client, line, col, completion_handler), bufnr)
    end)
end

M.config = {
    window = {
        border = nil, -- Signature border style
    },
    debounce_delay = 100
}

function M.capabilities()
    return {
        textDocument = {
            completion = {
                completionItem = {
                    -- Fetch additional info for completion items
                    resolveSupport = {
                        properties = {
                            'documentation',
                            'detail',
                            'additionalTextEdits'
                        },
                    },
                }
            },
        },
    }
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
    state.ns = vim.api.nvim_create_namespace('LspCompletion')
    local group = vim.api.nvim_create_augroup('LspCompletion', {})

    vim.api.nvim_create_autocmd('TextChangedI', {
        desc = 'Auto show LSP completion',
        group = group,
        callback = with_client(text_changed)
    })

    vim.api.nvim_create_autocmd('CompleteDone', {
        desc = 'Auto apply LSP completion edits after selection',
        group = group,
        callback = with_client(complete_done)
    })

    vim.api.nvim_create_autocmd('CompleteChanged', {
        desc = 'Auto update LSP completion info',
        group = group,
        callback = with_client(complete_changed)
    })
end

return M
