require('config.registry')
require('mason').setup({
    ui = {
        border = 'single',
    },
    registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
        'lua:config.registry',
    },
})

vim.api.nvim_create_user_command('MasonUpdateSync', function()
    vim.notify('Syncing packages...', vim.log.levels.INFO)

    local a = require('mason-core.async')
    local registry = require('mason-registry')
    local packages = vim.iter(require('config.languages'))
        :map(function(server)
            return server.mason
        end)
        :filter(function(server)
            return server
        end)
        :flatten()
        :totable()

    a.run_blocking(function()
        for _, name in ipairs(packages) do
            local pkg = registry.get_package(name)
            if not pkg:is_installed() then
                a.scheduler()
                vim.notify('Installing ' .. name, vim.log.levels.INFO)
                a.wait(function(resolve)
                    pkg:install():once('closed', resolve)
                end)
            else
                local installed_version = pkg:get_installed_version() or ''
                local latest_version = pkg:get_latest_version()
                if latest_version and installed_version ~= latest_version then
                    a.scheduler()
                    vim.notify(
                        'Updating ' .. name .. ' from ' .. installed_version .. ' to ' .. latest_version,
                        vim.log.levels.INFO
                    )
                    a.wait(function(resolve)
                        pkg:install({ version = latest_version }):once('closed', resolve)
                    end)
                end
            end
        end

        for _, name in ipairs(registry.get_installed_package_names()) do
            local pkg = registry.get_package(name)
            if not vim.tbl_contains(packages, name) then
                a.scheduler()
                vim.notify('Uninstalling ' .. name, vim.log.levels.INFO)
                a.wait(function(resolve)
                    pkg:uninstall():once('closed', resolve)
                end)
            end
        end
    end)

    vim.notify('Succesfully synced ' .. #packages .. ' packages.', vim.log.levels.INFO)
end, { force = true })
