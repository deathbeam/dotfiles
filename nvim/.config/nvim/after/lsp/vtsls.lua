return {
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
}
