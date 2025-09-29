return {
    filetypes = { 'python' },
    cmd = { 'pylance', '--stdio' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' },
    single_file_support = true,
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
}
