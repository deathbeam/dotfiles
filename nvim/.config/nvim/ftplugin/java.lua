-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/setup-with-nvim-jdtls.md

vim.g.java_ignore_markdown = true

local jdtls = require('jdtls')
local utils = require('config.utils')

local function prepare_jdtls()
    if vim.g.jdtls_data then
        return vim.g.jdtls_data
    end

    local languages = require('config.languages')
    local registry = require('mason-registry')
    local dap = require('dap')

    dap.configurations.java = {
        {
            type = 'java',
            request = 'attach',
            name = 'Attach to remote',
            connect = function()
                local host = vim.fn.input('Host [127.0.0.1]: ')
                host = host ~= '' and host or '127.0.0.1'
                local port = tonumber(vim.fn.input('Port [5005]: ')) or 5005
                return { host = host, port = port }
            end,
        },
    }

    local data = {}
    local jdtls_install = registry.get_package('jdtls'):get_install_path()

    data.settings = vim.tbl_filter(function(language)
        return language.mason and vim.tbl_contains(language.mason, 'jdtls')
    end, languages)[1].settings

    data.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'
    data.java_agent = jdtls_install .. '/lombok.jar'
    data.launcher_jar = vim.trim(vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'))
    if vim.fn.has('mac') == 1 then
        data.platform_config = jdtls_install .. '/config_mac'
    elseif vim.fn.has('unix') == 1 then
        data.platform_config = jdtls_install .. '/config_linux'
    elseif vim.fn.has('win32') == 1 then
        data.platform_config = jdtls_install .. '/config_win'
    end

    data.bundles = {}

    local java_test_path = registry.get_package('java-test'):get_install_path()
    local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar'), '\n')
    if java_test_bundle[1] ~= '' then
        vim.list_extend(data.bundles, java_test_bundle)
    end

    local java_debug_path = registry.get_package('java-debug-adapter'):get_install_path()
    local java_debug_bundle =
        vim.split(vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n')
    if java_debug_bundle[1] ~= '' then
        vim.list_extend(data.bundles, java_debug_bundle)
    end

    vim.g.jdtls_data = data
    return data
end

local function jdtls_on_attach(_, bufnr)
    local jdtls_dap = require('jdtls.dap')
    jdtls_dap.setup_dap({ hotcodereplace = 'auto' })
    jdtls_dap.setup_dap_main_class_configs()

    utils.nmap('<leader>dt', jdtls.test_nearest_method, 'Debug Test Method', bufnr)
    utils.nmap('<leader>dT', jdtls.test_class, 'Debug Test Class', bufnr)
end

local cwd = vim.fn.getcwd()
local data = prepare_jdtls()
local data_dir = data.data_dir .. '/' .. vim.fn.fnamemodify(cwd, ':p:h:t')

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
    '-javaagent:' .. data.java_agent,
    '-jar',
    data.launcher_jar,
    '-configuration',
    data.platform_config,
    '-data',
    data_dir,
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach({
    cmd = cmd,
    settings = data.settings,
    on_attach = jdtls_on_attach,
    capabilities = utils.make_capabilities(),
    root_dir = cwd,
    flags = {
        allow_incremental_sync = true,
    },
    init_options = {
        bundles = data.bundles,
    },
    handlers = {
        ['language/status'] = function() end,
        -- FIXME: Maybe check this again? https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/jdtls.lua#L117
    },
})
