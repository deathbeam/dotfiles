-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/setup-with-nvim-jdtls.md

vim.g.java_ignore_markdown = true

local jdtls = require('jdtls')

local function prepare_jdtls()
    if vim.g.jdtls_data then
        return vim.g.jdtls_data
    end

    require('dap').configurations.java = {
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
    local jdtls_path = vim.fn.expand('$MASON/share/jdtls')
    local java_test_path = vim.fn.expand('$MASON/share/java-test')
    local java_debug_path = vim.fn.expand('$MASON/share/java-debug-adapter')

    data.settings = vim.tbl_filter(function(language)
        return language.mason and vim.tbl_contains(language.mason, 'jdtls')
    end, require('config.languages'))[1].settings

    data.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'
    data.java_agent = jdtls_path .. '/lombok.jar'
    data.bundles = {}

    local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. '/*.jar'), '\n')
    if java_test_bundle[1] ~= '' then
        vim.list_extend(data.bundles, java_test_bundle)
    end

    local java_debug_bundle =
        vim.split(vim.fn.glob(java_debug_path .. '/com.microsoft.java.debug.plugin-*.jar'), '\n')
    if java_debug_bundle[1] ~= '' then
        vim.list_extend(data.bundles, java_debug_bundle)
    end

    vim.g.jdtls_data = data
    return data
end

local function jdtls_on_attach(_, bufnr)
    local utils = require('config.utils')
    utils.nmap('<leader>dt', jdtls.test_nearest_method, 'Debug Test Method', bufnr)
    utils.nmap('<leader>dT', jdtls.test_class, 'Debug Test Class', bufnr)
end

local cwd = vim.fn.getcwd()
local data = prepare_jdtls()

-- The command that starts the language server
-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
-- Also see: https://github.com/redhat-developer/vscode-java/blob/master/src/javaServerStarter.ts
local cmd = {
    'jdtls',
    '--jvm-arg=-javaagent:' .. data.java_agent,
    '-data', data.data_dir .. '/' .. vim.fn.fnamemodify(cwd, ':p:h:t'),
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach({
    cmd = cmd,
    settings = data.settings,
    on_attach = jdtls_on_attach,
    capabilities = require('myplugins.bufcomplete').capabilities(),
    root_dir = cwd,
    flags = {
        allow_incremental_sync = true,
    },
    init_options = {
        bundles = data.bundles,
    },
    handlers = {
        ['language/status'] = function() end,
    },
})
