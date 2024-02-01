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
        lsp_ignore = true,
        lsp_settings = {
            -- See: https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
            -- Also see: https://github.com/redhat-developer/vscode-java/blob/d3bcbaa3f5a3097dc21b5d94132d6858a0452a7c/package.json#L273
            java = {
                configuration = {
                    updateBuildConfiguration = "interactive",
                },
                eclipse = {
                    downloadSources = true,
                },
                maven = {
                    downloadSources = true,
                },
                references = {
                    includeAccessors = true,
                    includeDecompiledSources = true,
                },
                format = {
                    enabled = true,
                },
                signatureHelp = {
                    enabled = true,
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all",
                    }
                },
                completion = {
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*",
                    },
                },
                contentProvider = {
                    preferred = "fernflower",
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    }
                },
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                    },
                    useBlocks = true,
                },
            }
        }
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
