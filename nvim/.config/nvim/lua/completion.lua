require('copilot').setup({
  panel = {
    enabled = false
  },
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = false
    }
  }
})

local suggestion = require("copilot.suggestion")
local cmp = require('cmp')

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local next_cmp = cmp.mapping(function(fallback)
  if cmp.visible() then
    cmp.select_next_item({behavior = cmp.SelectBehavior.Insert})
  elseif suggestion.is_visible() then
    suggestion.accept()
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end)

local prev_cmp = cmp.mapping(function(fallback)
  if cmp.visible() then
    cmp.select_prev_item({behavior = cmp.SelectBehavior.Insert})
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end, { "i", "s" })

cmp.setup {
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp',
      entry_filter = function(entry)
        return cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
      end
    },
    { name = 'path' },
  }, {
    { name = 'buffer' }
  }),
  mapping = {
    ["<C-e>"] = cmp.mapping(function(fallback)
      if suggestion.is_visible() then
        suggestion.accept()
      elseif cmp.visible() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<Tab>"] = next_cmp,
    ["<S-Tab>"] = prev_cmp,
    ["<C-n>"] = next_cmp,
    ["<C-p>"] = prev_cmp,
  }
}
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { '!' }
      }
    }
  })
})
