return {
    settings = {
        -- See: https://luals.github.io/wiki/settings/
        Lua = {
            runtime = {
                version = 'LuaJIT',
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
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
