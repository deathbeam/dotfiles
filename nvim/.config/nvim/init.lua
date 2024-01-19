-- Load existing vimrc
vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

-- Utility functions
local nmap = function(keys, func, desc, buffer)
  vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
end

-- Icons
require('nvim-web-devicons').setup()

-- Tmux
require("tmux").setup {
  copy_sync = {
    enable = false
  }
}

-- Eyeliner
require('eyeliner').setup {
  highlight_on_key = true,
  dim = true,
}

-- Notifications
require("fidget").setup {
  notification = {
    override_vim_notify = true
  },
  logger = {
    level = vim.log.levels.INFO
  }
}

-- Color scheme
local function adjustColors()
  local base0A = '#' .. vim.g.base16_gui0A
  local base0D = '#' .. vim.g.base16_gui0D
  local base00 = '#' .. vim.g.base16_gui00
  local base03 = '#' .. vim.g.base16_gui03
  local base0B = '#' .. vim.g.base16_gui0B
  local base0E = '#' .. vim.g.base16_gui0E

  vim.api.nvim_set_hl(0, 'StatusLine', { fg = base00 })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = base03 })
  vim.api.nvim_set_hl(0, 'User1', { underline = true, bg = base0D, fg = base00 })
  vim.api.nvim_set_hl(0, 'User2', { underline = true, fg = base0D })
  vim.api.nvim_set_hl(0, 'User3', { underline = true, fg = base0B })
  vim.api.nvim_set_hl(0, 'User4', { underline = true, fg = base0E })
  vim.api.nvim_set_hl(0, 'User5', { underline = true, fg = base0A })
end
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Adjust colors',
  callback = adjustColors
})
adjustColors()

-- Define language servers
local servers = {
  css = {
    lsp = 'cssls',
  },
  html = {
    lsp = 'html',
  },
  javascript = {
    lsp = 'tsserver',
  },
  typescript = {
    lsp = 'tsserver',
  },
  markdown = {
    lsp = 'marksman',
  },
  python = {
    lsp = 'pyright',
  },
  java = {
    lsp = 'jdtls',
  },
  lua = {
    lsp = 'lua_ls',
    lsp_settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT'
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = {
            vim.env.VIMRUNTIME,
          }
        }
      }
    }
  },
  vim = {
    lsp = 'vimls',
  },
  yaml = {
    lsp = 'yamlls',
  },
  json = {
    lsp = 'jsonls',
  },
  xml = {
    lsp = 'lemminx',
  }
}

-- Key help
require("which-key").register {
  ['<leader>f'] = { name = "[F]inder", _ = 'which_key_ignore' },
  ['<leader>g'] = { name = "[G]it", _ = 'which_key_ignore' },
  ['<leader>c'] = { name = "[C]ode", _ = 'which_key_ignore' },
  ['<leader>w'] = { name = "[W]iki", _ = 'which_key_ignore' },
}

-- Syntax highlighting
require("nvim-treesitter.configs").setup {
  ensure_installed = vim.tbl_keys(servers),
  highlight = {
    enable = true
  },
  indent = {
    enable = true
  }
}

-- Fuzzy finder
local fzf_lua = require('fzf-lua')
fzf_lua.setup {
  'fzf-tmux',
  file_icon_padding = ' ',
  grep = {
    rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
  }
}
fzf_lua.register_ui_select()
vim.lsp.handlers["textDocument/codeAction"] = fzf_lua.lsp_code_actions
vim.lsp.handlers["textDocument/definition"] = fzf_lua.lsp_definitions
vim.lsp.handlers["textDocument/declaration"] = fzf_lua.lsp_declarations
vim.lsp.handlers["textDocument/typeDefinition"] = fzf_lua.lsp_typedefs
vim.lsp.handlers["textDocument/implementation"] = fzf_lua.lsp_implementations
vim.lsp.handlers["textDocument/references"] = fzf_lua.lsp_references
vim.lsp.handlers["textDocument/documentSymbol"] = fzf_lua.lsp_document_symbols
vim.lsp.handlers["workspace/symbol"] = fzf_lua.lsp_workspace_symbols
vim.lsp.handlers["callHierarchy/incomingCalls"] = fzf_lua.lsp_incoming_calls
vim.lsp.handlers["callHierarchy/outgoingCalls"] = fzf_lua.lsp_outgoing_calls

nmap('<leader>fg', '<cmd>FzfLua grep_project<cr>', '[F]ind [G]rep')
nmap('<leader>ff', '<cmd>FzfLua files<cr>', '[F]ind [F]iles')
nmap('<leader>fF', '<cmd>FzfLua git_files<cr>', '[F]ind Git [F]iles')
nmap('<leader>fa', '<cmd>FzfLua commands<cr>', '[F]ind [A]ctions')
nmap('<leader>fc', '<cmd>FzfLua git_bcommits<cr>', '[F]ind [C]ommits')
nmap('<leader>fC', '<cmd>FzfLua git_commits<cr>', '[F]ind All [C]ommits')
nmap('<leader>fb', '<cmd>FzfLua buffers<cr>', '[F]ind [B]uffers')
nmap('<leader>fh', '<cmd>FzfLua oldfiles<cr>', '[F]ind [H]istory')

-- Completion
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
        cmp.confirm({ select = true })
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
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})

-- LSP
local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
lsp_capabilities.textDocument.completion.completionItem.snippetSupport = false

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    nmap('K', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Documentation', event.buf)
    nmap('gd', '<cmd>lua vim.lsp.buf.definition()<cr>', '[G]oto [D]efinition', event.buf)
    nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', '[G]oto [D]eclaration', event.buf)
    nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', '[G]oto [I]mplementation', event.buf)
    nmap('go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', '[G]oto [O]verload', event.buf)
    nmap('gr', '<cmd>lua vim.lsp.buf.references()<cr>', '[G]oto [R]eferences', event.buf)
    nmap('gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', '[G]oto [S]ignature Help', event.buf)
    nmap('gl', '<cmd>lua vim.diagnostic.open_float()<cr>', '[G]oto [L]ine Diagnostics', event.buf)
    nmap('[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', 'Goto Previous [D]iagnostic', event.buf)
    nmap(']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', 'Goto Next [D]iagnostic', event.buf)

    -- find
    nmap('<leader>fd', '<cmd>FzfLua lsp_document_diagnostics<cr>', '[F]ind [D]iagnostics', event.buf)
    nmap('<leader>fD', '<cmd>FzfLua lsp_workspace_diagnostics<cr>', '[F]ind All [D]iagnostics', event.buf)
    nmap('<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', '[F]ind [S]ymbols', event.buf)
    nmap('<leader>fS', '<cmd>FzfLua lsp_workspace_symbols<cr>', '[F]ind All [S]ymbols', event.buf)

    -- code
    nmap('<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', '[C]ode [R]ename', event.buf)
    nmap('<leader>cf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', '[C]ode [F]ormat', event.buf)
    nmap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', '[C]ode [A]ction', event.buf)
  end
})

require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_values(vim.tbl_map(function(server) return server.lsp end, vim.tbl_filter(function(server) return server.lsp end, servers))),
  handlers = {
    function(server)
      if server == 'jdtls' then
        return
      end

      local settings = nil
      for _, server_config in pairs(servers) do
        if server_config.lsp == server then
          settings = server_config.lsp_settings
        end
      end
      lspconfig[server].setup({
        capabilities = lsp_capabilities,
        settings = settings,
      })
    end
  },
}

require('java')
