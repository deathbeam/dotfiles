-- Load existing vimrc
vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
]])

-- Motions
require('leap').create_default_mappings()
require('flit').setup()

-- Utility functions
local nmap = function(keys, func, desc, buffer)
    vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
end

-- Color scheme
local base16 = require('base16-colorscheme')
base16.load_from_shell()
vim.api.nvim_create_autocmd('BufEnter', {
    desc = 'Adjust colorscheme',
    callback = function()
        vim.api.nvim_set_hl(0, 'LineNr', {})
        vim.api.nvim_set_hl(0, 'SignColumn', {})
        vim.api.nvim_set_hl(0, 'FoldColumn', {})
        vim.api.nvim_set_hl(0, 'Search', { bg = base16.colors.base0A, fg = base16.colors.base00 })
        vim.api.nvim_set_hl(0, 'StatusLine', { fg = base16.colors.base00 })
        vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = base16.colors.base03 })
        vim.api.nvim_set_hl(0, 'VertSplit', { fg = base16.colors.base03 })
        vim.api.nvim_set_hl(0, 'Title', { fg = base16.colors.base03 })
        vim.api.nvim_set_hl(0, 'TabLineSel', { fg = base16.colors.base0D })
        vim.api.nvim_set_hl(0, 'TabLineFill', { fg = base16.colors.base03 })
        vim.api.nvim_set_hl(0, 'TabLine', { fg = base16.colors.base03 })
        vim.api.nvim_set_hl(0, 'User1', { underline = true, bg = base16.colors.base0D, fg = base16.colors.base00 })
        vim.api.nvim_set_hl(0, 'User2', { underline = true, fg = base16.colors.base0D })
        vim.api.nvim_set_hl(0, 'User3', { underline = true, fg = base16.colors.base0B })
        vim.api.nvim_set_hl(0, 'User4', { underline = true, fg = base16.colors.base0E })
        vim.api.nvim_set_hl(0, 'User5', { underline = true, fg = base16.colors.base0A })
    end
})

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
        lsp = 'pylsp',
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
fzf_lua.setup()
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
local cmp = require('cmp')
cmp.setup {
    sources = {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                cmp.mapping.complete()(fallback)
            end
        end),
        ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                cmp.mapping.complete()(fallback)
            end
        end)
    }
}

-- LSP
local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_status = require('lsp-status')
lsp_status.register_progress()
lsp_status.config({ status_symbol = ' ', current_function = false })
lsp_capabilities = vim.tbl_deep_extend('force', lsp_capabilities, lsp_status.capabilities)

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
    ensure_installed = vim.tbl_map(function(server) return server.lsp end, servers),
    handlers = {
        function(server)
            local settings = nil
            for _, server_config in pairs(servers) do
                if server_config.lsp == server then
                    settings = server_config.lsp_settings
                end
            end
            lspconfig[server].setup({
                capabilities = lsp_capabilities,
                on_attach = lsp_status.on_attach,
                settings = settings,
            })
        end
    },
}
