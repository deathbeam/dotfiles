-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/setup-with-nvim-jdtls.md

local jdtls = require('jdtls')
local jdtls_dap = require('jdtls.dap')
local registry = require('mason-registry')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local nmap = require('utils').nmap

local java_cmds = vim.api.nvim_create_augroup('java_cmds', {clear = true})
local cache_vars = {}

local function get_jdtls_paths()
    if cache_vars.paths then
        return cache_vars.paths
    end

    local path = {}

    path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

    local jdtls_install = registry.get_package('jdtls'):get_install_path()
    path.java_agent = jdtls_install .. '/lombok.jar'
    path.launcher_jar = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')

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
    local java_debug_bundle = vim.split(vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n')
    if java_debug_bundle[1] ~= '' then
        vim.list_extend(path.bundles, java_debug_bundle)
    end

    cache_vars.paths = path
    return path
end

local function get_jdtls_capabilities()
    if cache_vars.capabilities then
        return cache_vars.capabilities
    end

    jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
    cache_vars.capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        cmp_nvim_lsp.default_capabilities())

    return cache_vars.capabilities
end

local function enable_codelens(bufnr)
    pcall(vim.lsp.codelens.refresh)

    vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        group = java_cmds,
        desc = 'refresh codelens',
        callback = function()
            pcall(vim.lsp.codelens.refresh)
        end,
    })
end

local function enable_debugger(bufnr)
    jdtls.setup_dap({hotcodereplace = 'auto'})
    jdtls_dap.setup_dap_main_class_configs()
    nmap('<leader>dt', jdtls.test_nearest_method, '[D]ebug [T]est Method', bufnr)
    nmap('<leader>dT', jdtls.test_class, '[D]ebug [T]est Class', bufnr)
end

local function jdtls_on_attach(client, bufnr)
    enable_debugger(bufnr)
    enable_codelens(bufnr)
end

local function jdtls_setup()
    local cwd = vim.fn.getcwd()
    local path = get_jdtls_paths()
    local data_dir = path.data_dir .. '/' ..  vim.fn.fnamemodify(cwd, ':p:h:t')
    local capabilities = get_jdtls_capabilities()

    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    local cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. path.java_agent,
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        path.launcher_jar,
        '-configuration',
        path.platform_config,
        '-data',
        data_dir,
    }

    -- See: https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    local lsp_settings = {
        java = {
            configuration = {
                updateBuildConfiguration = 'interactive',
            },
            eclipse = {
                downloadSources = true,
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = true,
            },
            signatureHelp = {
                enabled = true,
            },
            completion = {
                favoriteStaticMembers = {
                    'org.hamcrest.MatcherAssert.assertThat',
                    'org.hamcrest.Matchers.*',
                    'org.hamcrest.CoreMatchers.*',
                    'org.junit.jupiter.api.Assertions.*',
                    'java.util.Objects.requireNonNull',
                    'java.util.Objects.requireNonNullElse',
                    'org.mockito.Mockito.*',
                },
            },
            contentProvider = {
                preferred = 'fernflower',
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                }
            },
            codeGeneration = {
                toString = {
                    template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                },
                useBlocks = true,
            },
        },
    }

    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    jdtls.start_or_attach({
        cmd = cmd,
        settings = lsp_settings,
        on_attach = jdtls_on_attach,
        capabilities = capabilities,
        root_dir = cwd,
        flags = {
            allow_incremental_sync = true,
        },
        init_options = {
            bundles = path.bundles,
        },
        handlers = {
            ['language/status'] = function() end,
        }
    })
end

vim.api.nvim_create_autocmd('FileType', {
    group = java_cmds,
    pattern = {'java'},
    desc = 'Setup jdtls',
    callback = jdtls_setup,
})
