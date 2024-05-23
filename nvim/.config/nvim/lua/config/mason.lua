require('config.registry')
require('mason').setup {
    ui = {
        border = "single",
    },
    registries = {
        "github:mason-org/mason-registry",
        "lua:config.registry",
    },
}

require('mason-tool-installer').setup({
    run_on_start = false,
    ensure_installed = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(
        function(server)
            return server.mason
        end,
        vim.tbl_filter(function(server)
            return server.mason
        end, require('config.languages'))
    ))),
})
