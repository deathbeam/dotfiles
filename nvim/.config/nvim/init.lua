vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
]])

-- WhichKey
require("which-key").register({
    f = { name = "finder" },
    g = { name = "git" },
    r = { name = "refactor" },
    w = { name = "wiki" },
}, { prefix = "<leader>" })

-- Treesitter
require("nvim-treesitter.configs").setup {
    ensure_installed = { "css", "html", "javascript", "typescript", "markdown", "lua", "python", "java" },
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

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
        vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)

        -- find
        vim.keymap.set('n', '<leader>fd', '<cmd>Diagnostics<cr>', opts)
        vim.keymap.set('n', '<leader>fD', '<cmd>DiagnosticsAll<cr>', opts)
        vim.keymap.set('n', '<leader>fs', '<cmd>DocumentSymbols<cr>', opts)
        vim.keymap.set('n', '<leader>fS', '<cmd>WorkspaceSymbols<cr>', opts)
        vim.keymap.set('n', '<leader>fp', '<cmd>Mason<cr>', opts)

        -- refactor
        vim.keymap.set('n', '<leader>rr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '<leader>rf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<leader>ra', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end
})

local lsp_status = require('lsp-status')
lsp_status.register_progress()
lsp_status.config({
    status_symbol = ' ',
    current_function = false,
})

local default_setup = function(server)
    lspconfig[server].setup({
        capabilities = lsp_capabilities,
        on_attach = lsp_status.on_attach,
    })
end

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'jdtls',                -- java
        'jedi_language_server', -- python,
        'tsserver',             -- typescript,
        'cssls',                -- css,
        'html',                 -- html,
        'lua_ls',               -- lua,
        'jsonls',               -- json
        'vimls',                -- vim,
        'yamlls',               -- yaml
        'lemminx',              -- xml,
        'marksman',             -- markdown
    },
    handlers = {
        default_setup,
        lua_ls = function()
            require('lspconfig').lua_ls.setup({
              settings = {
                Lua = {
                  runtime = {
                    version = 'LuaJIT'
                  },
                  diagnostics = {
                    globals = {'vim'},
                  },
                  workspace = {
                    library = {
                      vim.env.VIMRUNTIME,
                    }
                  }
                }
              }
            })
        end
    },
})

local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
    },
    mapping = cmp.mapping.preset.insert({
        -- Enter key confirms completion item
        ['<CR>'] = cmp.mapping.confirm({ select = false }),

        -- Ctrl + space triggers completion menu
        ['<C-Space>'] = cmp.mapping.complete(),
    })
})

require('fzf_lsp').setup()
