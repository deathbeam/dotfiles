return {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = {
                    'lua/?.lua',
                    'lua/?/init.lua',
                },
            },
            hint = {
                enable = true,
            },
            workspace = {
                library = {
                    vim.trim(vim.env.VIMRUNTIME),
                    '${3rd}/luv/library',
                    '${3rd}/busted/library',
                },
            },
            completion = {
                callSnippet = false,
                keywordSnippet = false,
            },
        },
    },
}
