local M = {}

local state = {
    ns = nil,
    signature_window = nil,
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

    entry.timer:start( ms, 0, vim.schedule_wrap(function()
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

local function get_client(bufnr)
    local clients = vim.lsp.get_clients({ bufnr, method = methods.textDocument_completion })
    if #clients == 0 then
        return nil
    end

    return clients[1]
end

local function apply_text_edits(client, edits, bufnr)
    -- TODO: What am I doing here?
    if not edits or vim.tbl_isempty(edits) then
        return
    end

    -- Use extmark to track relevant cursor position after text edits
    local cur_pos = vim.api.nvim_win_get_cursor(0)
    local extmark_id = vim.api.nvim_buf_set_extmark(0, state.ns, cur_pos[1] - 1, cur_pos[2], {})
    local offset_encoding = client.offset_encoding
    vim.lsp.util.apply_text_edits(edits, bufnr, offset_encoding)
    local extmark_data = vim.api.nvim_buf_get_extmark_by_id(0, state.ns, extmark_id, {})
    pcall(vim.api.nvim_buf_del_extmark, 0, state.ns, extmark_id)
    pcall(vim.api.nvim_win_set_cursor, 0, { extmark_data[1] + 1, extmark_data[2] })
end

local function complete_done(client, bufnr)
    local completed_item = vim.v.completed_item
    if not completed_item or not completed_item.user_data then
        return
    end

    local item = completed_item.user_data.nvim.lsp.completion_item
    if item.textEdit then
        apply_text_edits(client, { item.textEdit }, bufnr)
    end

    if #(item.additionalTextEdits or {}) == 0 then
        debounce('textEdits', M.config.debounce_delay, function()
            return request(client, methods.completionItem_resolve, item, function(_, result)
                apply_text_edits(client, result.additionalTextEdits, bufnr)
            end, bufnr)
        end)
    else
        apply_text_edits(client, item.additionalTextEdits, bufnr)
    end
end

local function complete_changed(client, bufnr)
    local completed_item = vim.v.event.completed_item
    if not completed_item or not completed_item.user_data then
        return
    end

    -- FIXME: Sometimes I do not receive updated complete_info (for example requests.get, 
    -- I get index 19 instead of 0 as its only match, when I press backspace it updates to 0)
    local data = vim.fn.complete_info()
    local selected = data.selected
    local item = completed_item.user_data.nvim.lsp.completion_item

    debounce('info', M.config.debounce_delay, function()
        return request(client, methods.completionItem_resolve, item, function(_, result)
            local info = vim.fn.complete_info()

            -- FIXME: Preview popup is kinda garbage so we need to reload it like this
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
    vim.schedule(function()
        local mode = vim.api.nvim_get_mode()['mode']
        if mode == 'i' or mode == 'ic' then
            vim.fn.complete(cmp_start + 1, items)
        end
    end)
end

local function cleanup_windows(client, bufnr)
    if state.signature_window and vim.api.nvim_win_is_valid(state.signature_window) then
        vim.api.nvim_win_close(state.signature_window, true)
        state.signature_window = nil
    end
end

local function signature_handler(client, line, col, result, ctx)
    local triggers = vim.tbl_get(client.server_capabilities, 'signatureHelpProvider', 'triggerCharacters')
    local ft = vim.bo[ctx.bufnr].filetype
    local lines, hl = vim.lsp.util.convert_signature_help_to_markdown_lines(result, ft, triggers)
    if not lines or vim.tbl_isempty(lines) then
        cleanup_windows(client, ctx.bufnr)
        return
    end
    lines = { unpack(lines, 1, 3) }
    local _, fwin = vim.lsp.util.open_floating_preview(lines, 'markdown', {
        close_events = {},
        border = M.config.window.border,
    })

    state.signature_window = fwin
end

local function text_changed(client, bufnr)
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 or #line == 0 then
        return
    end

    local before_line = line:sub(1, col)
    local char = line:sub(col, col)
    local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), client.offset_encoding)
    local sig_found = false

    for _, c in ipairs(client.server_capabilities.signatureHelpProvider.triggerCharacters or {}) do
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
        cleanup_windows(client, bufnr)
    end

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
        border = 'single',
    },
    debounce_delay = 100
}

function M.capabilities()
    return {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = false,
                    resolveSupport = {
                        properties = { 'edit', 'documentation', 'detail', 'additionalTextEdits' },
                    },
                },
                completionList = {
                    itemDefaults = {
                        'editRange',
                        'insertTextFormat',
                        'insertTextMode',
                        'data',
                    },
                },
            },
        },
    }
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
    state.ns = vim.api.nvim_create_namespace('LspCompletion')
    local group = vim.api.nvim_create_augroup('LspCompletion', {})

    vim.api.nvim_create_autocmd('TextChangedI', { group = group, callback = function(args)
        local bufnr = args.buf
        local client = get_client(bufnr)
        if client then
            text_changed(client, bufnr)
        end
    end })

    vim.api.nvim_create_autocmd('CompleteDone', { group = group, callback = function(args)
        local bufnr = args.buf
        local client = get_client(bufnr)
        if client then
            complete_done(client, bufnr)
        end
    end })

    vim.api.nvim_create_autocmd('CompleteChanged', { group = group, callback = function(args)
        local bufnr = args.buf
        local client = get_client(bufnr)
        if client then
            complete_changed(client, bufnr)
        end
    end })

    vim.api.nvim_create_autocmd('CursorMoved', { group = group, callback = function(args)
        local bufnr = args.buf
        local client = get_client(bufnr)
        if client then
            cleanup_windows(client, bufnr)
        end
    end })
end

return M
