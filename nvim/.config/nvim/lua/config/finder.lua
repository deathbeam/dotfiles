local nmap = require('config/utils').nmap

require("which-key").register {
    ['<leader>f'] = { name = "[F]inder", _ = 'which_key_ignore' }
}

local fzf_lua = require('fzf-lua')
fzf_lua.setup {
    'fzf-tmux',
    fzf_opts = {
        ["--border"] = "sharp",
        ["--preview-window"] = "border-sharp"
    },
    file_icon_padding = ' ',
    -- FIXME: wait for fix for https://github.com/mfussenegger/nvim-jdtls/issues/608
    lsp = {
        code_actions = {
            previewer = false
        }
    },
    grep = {
        rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
    }
}
fzf_lua.register_ui_select()
vim.lsp.handlers["textDocument/codeAction"] = fzf_lua.lsp_code_actions
vim.lsp.handlers["textDocument/definition"] = fzf_lua.lsp_definitions
vim.lsp.handlers["textDocument/declaration"] = fzf_lua.lsp_declarations
vim.lsp.handlers["textDocument/typeDefinition"] = fzf_lua.lsp_typedefs
vim.lsp.handlers["textDocument/implementation"] = fzf_lua.lsp_implementations
vim.lsp.handlers["textDocument/references"] = fzf_lua.lsp_references
vim.lsp.handlers["textDocument/documentSymbol"] = fzf_lua.lsp_document_symbols
vim.lsp.handlers["workspace/symbol"] = fzf_lua.lsp_workspace_symbols
vim.lsp.handlers["callHierarchy/incomingCalls"] = fzf_lua.lsp_incoming_calls
vim.lsp.handlers["callHierarchy/outgoingCalls"] = fzf_lua.lsp_outgoing_calls

nmap('<leader>fg', fzf_lua.grep_project, '[F]ind [G]rep')
nmap('<leader>ff', fzf_lua.files, '[F]ind [F]iles')
nmap('<leader>fF', fzf_lua.git_files, '[F]ind Git [F]iles')
nmap('<leader>fa', fzf_lua.commands, '[F]ind [A]ctions')
nmap('<leader>fc', fzf_lua.git_bcommits, '[F]ind [C]ommits')
nmap('<leader>fC', fzf_lua.git_commits, '[F]ind All [C]ommits')
nmap('<leader>fb', fzf_lua.buffers, '[F]ind [B]uffers')
nmap('<leader>fh', fzf_lua.oldfiles, '[F]ind [H]istory')
