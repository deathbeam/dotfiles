return {
    {
        treesitter = { 'javascript', 'typescript' },
        mason = { 'typescript-language-server', 'js-debug-adapter' },
        lsp = { 'tsserver' },
        settings = {
            -- See: https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
            implicitProjectConfiguration = {
                checkJs = true,
                target = 'ES2022',
            },
            javascript = {
                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = 'all',
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
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                },
            },
        },
    },
    {
        treesitter = { 'python' },
        mason = { 'pylance', 'debugpy' },
        lsp = { 'pylance' },
        settings = {
            -- See: https://github.com/microsoft/pyright/blob/main/docs/settings.md
            -- See: https://code.visualstudio.com/docs/python/settings-reference
            python = {
                pythonPath = vim.fn.exepath('python'),
                analysis = {
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        callArgumentNames = true,
                        pytestParameters = true,
                    },
                    typeCheckingMode = 'basic',
                    diagnosticMode = 'openFilesOnly',
                    autoImportCompletions = true,
                    diagnosticSeverityOverrides = {
                        reportOptionalSubscript = 'none',
                        reportOptionalMemberAccess = 'none',
                        reportOptionalCall = 'none',
                        reportOptionalIterable = 'none',
                        reportOptionalContextManager = 'none',
                        reportOptionalOperand = 'none',
                    },
                },
            },
        },
    },
    {
        treesitter = { 'java' },
        mason = { 'jdtls', 'java-debug-adapter', 'java-test' },
        settings = {
            -- See: https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
            -- Also see: https://github.com/redhat-developer/vscode-java/blob/d3bcbaa3f5a3097dc21b5d94132d6858a0452a7c/package.json#L273
            java = {
                configuration = {
                    updateBuildConfiguration = 'interactive',
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
                        enabled = 'all',
                    },
                },
                completion = {
                    favoriteStaticMembers = {
                        'org.hamcrest.MatcherAssert.assertThat',
                        'org.hamcrest.Matchers.*',
                        'org.hamcrest.CoreMatchers.*',
                        'org.junit.jupiter.api.Assertions.*',
                        'java.util.Objects.requireNonNull',
                        'java.util.Objects.requireNonNullElse',
                        'org.mockito.Mockito.*',
                    },
                },
                contentProvider = {
                    preferred = 'fernflower',
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    },
                },
                codeGeneration = {
                    toString = {
                        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                    },
                    useBlocks = true,
                },
            },
        },
    },
    {
        treesitter = { 'lua' },
        mason = { 'lua-language-server' },
        lsp = { 'lua_ls' },
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME,
                    },
                },
            },
        },
    },
    {
        treesitter = { 'gdscript' },
        lsp = { 'gdscript' },
    },
    {
        treesitter = { 'bash' },
        mason = { 'bash-language-server' },
        lsp = { 'bashls' },
    },
    {
        treesitter = { 'vim', 'vimdoc' },
        mason = { 'vim-language-server' },
        lsp = { 'vimls' },
    },
    {
        treesitter = { 'yaml' },
        mason = { 'yaml-language-server' },
        lsp = { 'yamlls' },
    },
    {
        treesitter = { 'css' },
        mason = { 'css-lsp' },
        lsp = { 'cssls' },
    },
    {
        treesitter = { 'html' },
        mason = { 'html-lsp' },
        lsp = { 'html' },
    },
    {
        treesitter = { 'markdown' },
        mason = { 'marksman' },
        lsp = { 'marksman' },
    },
    {
        treesitter = { 'json' },
    },
    {
        treesitter = { 'xml' },
    },
    {
        treesitter = { 'diff', 'gitcommit' },
    },
}
