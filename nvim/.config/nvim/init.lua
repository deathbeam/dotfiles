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
  python = {
    lsp = 'pyright',
  },
  java = {
    lsp = 'jdtls',
    dap = { 'java-debug-adapter', 'java-test' },
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
  bash = {
    lsp = 'bashls',
  },
  vim = {
    lsp = 'vimls',
  },
  markdown = {
    lsp = 'marksman',
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
  fzf_opts = {
    ["--border"] = "sharp",
    ["--preview-window"] = "border-sharp"
  },
  file_icon_padding = ' ',
  -- FIXME: wait for fix for https://github.com/mfussenegger/nvim-jdtls/issues/608
  lsp = {
    code_actions = {
      previewer = false
    }
  },
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

nmap('<leader>fg', fzf_lua.grep_project, '[F]ind [G]rep')
nmap('<leader>ff', fzf_lua.files, '[F]ind [F]iles')
nmap('<leader>fF', fzf_lua.git_files, '[F]ind Git [F]iles')
nmap('<leader>fa', fzf_lua.commands, '[F]ind [A]ctions')
nmap('<leader>fc', fzf_lua.git_bcommits, '[F]ind [C]ommits')
nmap('<leader>fC', fzf_lua.git_commits, '[F]ind All [C]ommits')
nmap('<leader>fb', fzf_lua.buffers, '[F]ind [B]uffers')
nmap('<leader>fh', fzf_lua.oldfiles, '[F]ind [H]istory')

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
    nmap('K', vim.lsp.buf.hover, 'Documentation', event.buf)
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition', event.buf)
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration', event.buf)
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation', event.buf)
    nmap('go', vim.lsp.buf.type_definition, '[G]oto [O]verload', event.buf)
    nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences', event.buf)
    nmap('gs', vim.lsp.buf.signature_help, '[G]oto [S]ignature Help', event.buf)
    nmap('gl', vim.diagnostic.open_float, '[G]oto [L]ine Diagnostics', event.buf)
    nmap('[d', vim.diagnostic.goto_prev, 'Goto Previous [D]iagnostic', event.buf)
    nmap(']d', vim.diagnostic.goto_next, 'Goto Next [D]iagnostic', event.buf)

    -- find
    nmap('<leader>fd', fzf_lua.lsp_document_diagnostics, '[F]ind [D]iagnostics', event.buf)
    nmap('<leader>fD', fzf_lua.lsp_workspace_diagnostics, '[F]ind All [D]iagnostics', event.buf)
    nmap('<leader>fs', fzf_lua.lsp_document_symbols, '[F]ind [S]ymbols', event.buf)
    nmap('<leader>fS', fzf_lua.lsp_live_workspace_symbols, '[F]ind All [S]ymbols', event.buf)

    -- code
    nmap('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename', event.buf)
    nmap('<leader>cf', vim.lsp.buf.format, '[C]ode [F]ormat', event.buf)
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', event.buf)
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

-- DAP
local dap, dapui = require("dap"), require("dapui")
require("nvim-dap-virtual-text").setup()
require("mason-nvim-dap").setup({
    ensure_installed = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(function(server) return server.dap end, vim.tbl_filter(function(server) return server.dap end, servers)))),
})
dapui.setup()
dap.listeners.before.attach.dapui_config = dapui.open
dap.listeners.before.launch.dapui_config = dapui.open
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close
nmap('<leader>dc', dap.continue, '[D]ebug [C]ontinue')
nmap('<leader>dx', function()
  dap.disconnect({ terminateDebuggee = true })
  dap.close()
  dapui.close()
end, '[D]ebug E[X]it')
nmap('<leader>ds', dap.step_over, '[D]ebug [S]tep')
nmap('<leader>di', dap.step_into, '[D]ebug [I]nto')
nmap('<leader>do', dap.step_out, '[D]ebug [O]ut')
nmap('<leader>db', dap.toggle_breakpoint, '[D]ebug [B]reakpoint')
nmap('<leader>dB', function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, '[D]ebug Conditional [B]reakpoint')
nmap('<leader>dr', dap.repl.open, '[D]ebug [R]epl')
nmap('<leader>dl', dap.run_last, '[D]ebug [L]ast')
nmap('<leader>du', dapui.toggle, '[D]ebug [U]I Toggle')
nmap('<leader>fp', fzf_lua.dap_breakpoints, '[F]ind Break[P]oints')

require('java')
