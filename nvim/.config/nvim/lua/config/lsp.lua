local fzf = require('fzf-lua')
local languages = require('config.languages')
local icons = require('config.icons')
local utils = require('config.utils')
local nmap = utils.nmap
local au = utils.au
local desc = utils.desc

local function w(fn)
    return function(...)
        return fn({
            ignore_current_line = true,
            jump1 = true,
            includeDeclaration = false,
        }, ...)
    end
end

vim.diagnostic.config({
    severity_sort = true,
    virtual_text = false,
    virtual_lines = {
        current_line = true,
    },
    float = {
        border = 'single',
        focusable = false,
    },
    jump = {
        _highest = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.Error,
            [vim.diagnostic.severity.WARN] = icons.Warn,
            [vim.diagnostic.severity.INFO] = icons.Info,
            [vim.diagnostic.severity.HINT] = icons.Hint,
        },
    },
})

vim.lsp.semantic_tokens.enable(false)

-- Setup LSP mappings
-- :h lsp-defaults
au('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        -- disable semantic tokens
        client.server_capabilities.semanticTokensProvider = nil

        -- enable lsp folding
        if client:supports_method('textDocument/foldingRange') then
            vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        -- enable lsp completion
        if client:supports_method('textDocument/completion') then
            vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
            vim.lsp.completion.enable(true, client.id, event.buf, {
                convert = function(item)
                    local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Unknown'
                    local icon = icons.kinds[kind]
                    return {
                        kind = icon and icon .. ' ' .. kind or kind,
                    }
                end,
            })
        end

        -- enable inline completion
        if client:supports_method('textDocument/inlineCompletion') then
            vim.lsp.inline_completion.enable(true)
            vim.keymap.set('i', '<S-Tab>', function()
                if not vim.lsp.inline_completion.get() then
                    return '<S-Tab>'
                end
            end, { expr = true, desc = 'Accept Inline Completion' })
        end

        -- lsp mappings
        desc('<leader>c', 'Code')
        nmap('<leader>cr', vim.lsp.buf.rename, 'Rename', event.buf)
        nmap('<leader>ch', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, 'Inlay Hints', event.buf)
        nmap('<leader>ca', fzf.lsp_code_actions, 'Code Action', event.buf)

        nmap('gr', w(fzf.lsp_references), 'References', event.buf)
        nmap('gi', w(fzf.lsp_implementations), 'Implementation', event.buf)
        nmap('gd', w(fzf.lsp_definitions), 'Definition', event.buf)
        nmap('gD', w(fzf.lsp_declarations), 'Declaration', event.buf)
        nmap('gy', w(fzf.lsp_typedefs), 'Type Definition', event.buf)
    end,
})

-- Setup LSP servers
for _, language in ipairs(languages) do
    if language.setup then
        language.setup()
    end

    for _, lsp in ipairs(language.lsp or {}) do
        vim.lsp.config(lsp, {
            cmd = language.cmd,
            settings = language.settings,
        })
        vim.lsp.enable(lsp)
    end
end
