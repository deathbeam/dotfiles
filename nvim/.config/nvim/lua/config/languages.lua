return {
    css = {
        mason = { 'cssls' },
    },
    html = {
        mason = { 'html' },
    },
    javascript = {
        mason = { 'tsserver' },
        lsp_settings = {
            javascript = {
                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                },
            },

            typescript = {
                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                },
            },
        }
    },
    typescript = {
        mason = { 'tsserver' },
    },
    python = {
        mason = { 'pyright', 'debugpy' },
    },
    java = {
        mason = { 'jdtls', 'java-debug-adapter', 'java-test' },
        lsp_ignore = true
    },
    lua = {
        mason = { 'lua_ls' },
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
        mason = { 'bashls' },
    },
    vim = {
        mason = { 'vimls' },
    },
    markdown = {
        mason = { 'marksman' },
    },
    yaml = {
        mason = { 'yamlls' },
    },
    json = {
        mason = { 'jsonls' },
    },
    xml = {
        mason = { 'lemminx' },
    }
}
