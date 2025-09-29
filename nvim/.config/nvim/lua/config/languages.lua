return {
    {
        treesitter = { 'javascript', 'typescript' },
        mason = { 'vtsls', 'js-debug-adapter' },
        lsp = { 'vtsls' },
    },
    {
        treesitter = { 'python' },
        -- mason = { 'ty' },
        -- lsp = { 'ty' },
        mason = { 'pylance', 'debugpy' },
        lsp = { 'pylance' },
    },
    {
        treesitter = { 'java' },
        mason = { 'jdtls', 'java-debug-adapter', 'java-test', 'vscode-spring-boot-tools' },
        lsp = { 'jdtls' },
    },
    {
        treesitter = { 'c_sharp' },
        mason = { 'roslyn', 'netcoredbg' },
        lsp = { 'roslyn' },
    },
    {
        treesitter = { 'c' },
        mason = { 'clangd' },
        lsp = { 'clangd' },
    },
    {
        treesitter = { 'nim' },
        -- needs manual install, choosenim-bin, nimlangserver-git
        -- mason = { 'nimlangserver' },
        lsp = { 'nim_langserver' },
    },
    {
        treesitter = { 'lua' },
        -- mason = { 'emmylua_ls' },
        -- lsp = { 'emmylua_ls' },
        mason = { 'lua-language-server' },
        lsp = { 'lua_ls' },
    },
    {
        treesitter = { 'bash' },
        mason = { 'bash-language-server' },
        lsp = { 'bashls' },
    },
    {
        treesitter = { 'vim', 'vimdoc' },
        mason = { 'vim-language-server' },
        lsp = { 'vimls' },
    },
    {
        treesitter = { 'yaml' },
        mason = { 'yaml-language-server' },
        lsp = { 'yamlls' },
    },
    {
        treesitter = { 'css' },
        mason = { 'css-lsp' },
        lsp = { 'cssls' },
    },
    {
        treesitter = { 'html' },
        mason = { 'html-lsp' },
        lsp = { 'html' },
    },
    {
        treesitter = { 'markdown', 'markdown_inline' },
        mason = { 'marksman' },
        lsp = { 'marksman' },
    },
    {
        treesitter = { 'json' },
    },
    {
        treesitter = { 'xml' },
    },
    {
        treesitter = { 'diff', 'gitcommit' },
    },
    {
        treesitter = { 'http' },
    },
    {
        mason = { 'harper-ls' },
        lsp = { 'harper_ls' },
    },
    {
        mason = { 'copilot-language-server' },
        lsp = { 'copilot' },
    },
}
