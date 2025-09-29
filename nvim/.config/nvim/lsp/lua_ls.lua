return {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            hint = {
                enable = true,
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
            completion = {
                callSnippet = 'Disable',
                keywordSnippet = 'Disable',
            },
        },
    },
}
