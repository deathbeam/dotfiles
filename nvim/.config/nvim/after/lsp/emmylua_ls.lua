return {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                requirePattern = {
                    'lua/?.lua',
                    'lua/?/init.lua',
                },
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME
                },
            },
        },
    },
}
