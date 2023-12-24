-- Load existing vimrc
vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
]])

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


-- WhichKey
require("which-key").register {
    ['<leader>f'] = { name = "[F]inder", _ = 'which_key_ignore' },
    ['<leader>g'] = { name = "[G]it", _ = 'which_key_ignore' },
    ['<leader>c'] = { name = "[C]ode", _ = 'which_key_ignore' },
    ['<leader>w'] = { name = "[W]iki", _ = 'which_key_ignore' },
}

-- Treesitter
require("nvim-treesitter.configs").setup {
    ensure_installed = vim.tbl_keys(servers),
    sync_install = false,
    auto_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true
    }
}

-- LSP
local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_status = require('lsp-status')
lsp_status.register_progress()
lsp_status.config({ status_symbol = ' ', current_function = false })
lsp_capabilities = vim.tbl_deep_extend('force', lsp_capabilities, lsp_status.capabilities)
require('fzf_lsp').setup()

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local nmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
        end

        nmap('K', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover documentation')
        nmap('gd', '<cmd>lua vim.lsp.buf.definition()<cr>', '[G]oto [D]efinition')
        nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', '[G]oto [D]eclaration')
        nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', '[G]oto [I]mplementation')
        nmap('go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', '[G]oto [O]verload')
        nmap('gr', '<cmd>lua vim.lsp.buf.references()<cr>', '[G]oto [R]eferences')
        nmap('gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', '[G]oto [S]ignature help')
        nmap('gl', '<cmd>lua vim.diagnostic.open_float()<cr>', '[G]oto [L]ine diagnostics')
        nmap('gL', '<cmd>lua vim.diagnostic.setloclist()<cr>', '[G]oto [L]ist diagnostics')
        nmap('[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', 'Goto previous diagnostic')
        nmap(']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', 'Goto next diagnostic')

        -- find
        nmap('<leader>fd', '<cmd>Diagnostics<cr>', '[F]ind [D]iagnostics')
        nmap('<leader>fD', '<cmd>DiagnosticsAll<cr>', '[F]ind All [D]iagnostics')
        nmap('<leader>fs', '<cmd>DocumentSymbols<cr>', '[F]ind [S]ymbols')
        nmap('<leader>fS', '<cmd>WorkspaceSymbols<cr>', '[F]ind All [S]ymbols')
        nmap('<leader>fp', '<cmd>Mason<cr>', '[F]ind [P]lugins')

        -- code
        nmap('<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', '[C]ode [R]ename')
        nmap('<leader>cf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', '[C]ode [F]ormat')
        nmap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', '[C]ode [A]ction')
    end
})

require('mason').setup({})
require('mason-lspconfig').setup({
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
})

local cmp = require('cmp')
cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'buffer' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
    })
})
