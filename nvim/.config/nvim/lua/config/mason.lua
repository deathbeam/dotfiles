require('config.registry')
require('mason').setup({
    ui = {
        border = 'single',
    },
    registries = {
        'github:mason-org/mason-registry',
        'lua:config.registry',
    },
})

vim.api.nvim_create_user_command('MasonUpdateSync', function()
    local a = require('mason-core.async')
    local registry = require('mason-registry')
    local packages = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(
        function(server)
            return server.mason
        end,
        vim.tbl_filter(function(server)
            return server.mason
        end, require('config.languages'))
    )))

    a.run_blocking(function()
        for _, name in ipairs(packages) do
            local pkg = registry.get_package(name)
            if not pkg:is_installed() then
                vim.notify('Installing ' .. name, vim.log.levels.INFO)
                a.wait(function(resolve)
                    pkg:install():once('closed', resolve)
                end)
            else
                local new_version, version_info = a.wait(function(resolve)
                    pkg:check_new_version(resolve)
                end)
                if new_version then
                    vim.notify('Updating ' .. name .. ' to ' .. version_info.latest, vim.log.levels.INFO)
                    a.wait(function(resolve)
                        pkg:install({ version = version_info.latest }):once('closed', resolve)
                    end)
                end
            end
        end
    end)

    vim.notify('MasonUpdateSync finished', vim.log.levels.INFO)
end, { force = true })
