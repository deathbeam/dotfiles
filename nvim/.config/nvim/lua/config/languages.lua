return {
    {
        treesitter = { 'javascript', 'typescript' },
        mason = { 'vtsls', 'js-debug-adapter' },
        lsp = { 'vtsls' },
        settings = {
            -- See: https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
            -- See: https://github.com/yioneko/vtsls/blob/main/packages/service/conjfiguration.schema.json
            ['js/ts'] = {
                implicitProjectConfig = {
                    checkJs = true,
                    target = 'ES2022',
                },
            },
            javascript = {
                inlayHints = {
                    parameterNames = { enabled = 'literals' },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                },
            },
            typescript = {
                inlayHints = {
                    parameterNames = { enabled = 'literals' },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
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
                    updateBuildConfiguration = 'automatic',
                },
                eclipse = {
                    downloadSources = true,
                },
                maven = {
                    downloadSources = true,
                },
                format = {
                    enabled = true,
                },
                signatureHelp = {
                    enabled = true,
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
                    useBlocks = true,
                },
            },
        },
    },
    {
        treesitter = { 'c_sharp' },
        mason = { 'csharp-language-server' },
        lsp = { 'csharp_ls' },
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
        treesitter = { 'markdown', 'markdown_inline' },
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
    {
        treesitter = { 'http' }
    }
}
