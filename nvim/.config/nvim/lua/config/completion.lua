require("copilot").setup({
    panel = {
        enabled = false
    },
    suggestion = {
        auto_trigger = true,
        keymap = {
            accept = false,
            next = false,
            prev = false,
            dismiss = false
        }
    }
})

local icons = require("config.icons")
local suggestion = require("copilot.suggestion")
local cmp = require("cmp")

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
    preselect = true,
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    formatting = {
        format = function(_, item)
            if icons.kinds[item.kind] then
                item.kind = icons.kinds[item.kind] .. ' ' .. item.kind
            end
            return item
        end,
    },
    sources = cmp.config.sources(
        {
            {
                name = "nvim_lsp",
                entry_filter = function(entry)
                    return cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
                end
            },
            {
                name = "path"
            },
        },
        {
            {
                name = "buffer"
            }
        }
    ),
    mapping = {
        ["<C-e>"] = cmp.mapping(function(fallback)
            if suggestion.is_visible() then
                suggestion.accept()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif suggestion.is_visible() then
                suggestion.next()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif suggestion.is_visible() then
                suggestion.prev()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
    }
}

cmp.setup.cmdline({"/", "?"}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" }
    }
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline {
        ['<Tab>'] = {
            c = function()
                local expand = false
                if vim.api.nvim_get_mode().mode == 'c' then
                    local text = vim.fn.getcmdline()
                    local expanded = vim.fn.expandcmd(text)
                    if expanded ~= text then
                        expand = true
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, true, true) .. expanded, 'n', false)
                        cmp.complete()
                    end
                end

                if expand then
                    return
                elseif cmp.visible() then
                    cmp.confirm()
                else
                    cmp.complete()
                end
            end
        }
    },
    sources = cmp.config.sources(
        { { name = "path" } },
        { { name = "cmdline" } }
    )
})
