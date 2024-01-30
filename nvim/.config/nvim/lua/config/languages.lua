return {
    {
        language = { "css"},
        mason = { "cssls" },
    },
    {
        language = { "html"},
        mason = { "html" },
    },
    {
        language = { "javascript", "typescript" },
        mason = { "tsserver", "js-debug-adapter" },
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
    {
        language = { "python" },
        mason = { "pyright", "debugpy" },
    },
    {
        language = { "java" },
        mason = { "jdtls", "java-debug-adapter", "java-test" },
        lsp_ignore = true
    },
    {
        language = { "lua" },
        mason = { "lua_ls" },
        lsp_settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT"
                },
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME,
                    }
                }
            }
        }
    },
    {
        language = { "bash" },
        mason = { "bashls" },
    },
    {
        language = { "vim" },
        mason = { "vimls" },
    },
    {
        language = { "markdown" },
        mason = { "marksman" },
    },
    {
        language = { "yaml" },
        mason = { "yamlls" },
    },
    {
        language = { "json" },
        mason = { "jsonls" },
    },
    {
        language = { "xml" },
        mason = { "lemminx" },
    }
}
