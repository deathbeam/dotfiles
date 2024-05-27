-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/setup-with-nvim-jdtls.md

local languages = require('config.languages')
local jdtls = require('jdtls')
local jdtls_dap = require('jdtls.dap')
local registry = require('mason-registry')
local dap = require('dap')
local utils = require('config.utils')
local nmap = utils.nmap
local au = utils.au
local lsp_capabilities = utils.make_capabilities()
local cache_vars = {}

local function get_jdtls_paths()
    if cache_vars.paths then
        return cache_vars.paths
    end

    local path = {}
    local jdtls_install = registry.get_package('jdtls'):get_install_path()

    path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'
    path.java_agent = jdtls_install .. '/lombok.jar'
    path.launcher_jar = vim.trim(vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'))
    if vim.fn.has('mac') == 1 then
        path.platform_config = jdtls_install .. '/config_mac'
    elseif vim.fn.has('unix') == 1 then
        path.platform_config = jdtls_install .. '/config_linux'
    elseif vim.fn.has('win32') == 1 then
        path.platform_config = jdtls_install .. '/config_win'
    end

    path.bundles = {}

    local java_test_path = registry.get_package('java-test'):get_install_path()
    local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar'), '\n')
    if java_test_bundle[1] ~= '' then
        vim.list_extend(path.bundles, java_test_bundle)
    end

    local java_debug_path = registry.get_package('java-debug-adapter'):get_install_path()
    local java_debug_bundle =
        vim.split(vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n')
    if java_debug_bundle[1] ~= '' then
        vim.list_extend(path.bundles, java_debug_bundle)
    end

    cache_vars.paths = path
    return path
end

local function jdtls_on_attach(_, bufnr)
    jdtls_dap.setup_dap({ hotcodereplace = 'auto' })
    jdtls_dap.setup_dap_main_class_configs()

    nmap('<leader>dt', jdtls.test_nearest_method, 'Debug Test Method', bufnr)
    nmap('<leader>dT', jdtls.test_class, 'Debug Test Class', bufnr)
end

au('FileType', {
    pattern = { 'java' },
    desc = 'Setup java',
    callback = function()
        if not cache_vars.dap_setup then
            cache_vars.dap_setup = true
            dap.configurations.java = {
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach remote',
                    hostName = 'localhost',
                    port = 5005,
                },
            }
        end

        local cwd = vim.fn.getcwd()
        local path = get_jdtls_paths()
        local data_dir = path.data_dir .. '/' .. vim.fn.fnamemodify(cwd, ':p:h:t')

        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        -- Also see: https://github.com/redhat-developer/vscode-java/blob/master/src/javaServerStarter.ts
        local cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Djava.import.generatesMetadataFilesAtProjectRoot=false',
            '-Xlog:disable',
            '-Xms1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens',
            'java.base/java.util=ALL-UNNAMED',
            '--add-opens',
            'java.base/java.lang=ALL-UNNAMED',
            '-javaagent:' .. path.java_agent,
            '-jar',
            path.launcher_jar,
            '-configuration',
            path.platform_config,
            '-data',
            data_dir,
        }

        -- This starts a new client & server,
        -- or attaches to an existing client & server depending on the `root_dir`.
        jdtls.start_or_attach({
            cmd = cmd,
            settings = vim.tbl_filter(function(language)
                return language.mason and vim.tbl_contains(language.mason, 'jdtls')
            end, languages)[1].settings,
            on_attach = jdtls_on_attach,
            capabilities = lsp_capabilities,
            root_dir = cwd,
            flags = {
                allow_incremental_sync = true,
            },
            init_options = {
                bundles = path.bundles,
            },
            handlers = {
                ['language/status'] = function() end,
                -- FIXME: Maybe check this again? https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/jdtls.lua#L117
            },
        })
    end,
})
