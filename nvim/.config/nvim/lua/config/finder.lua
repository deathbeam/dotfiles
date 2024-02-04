local utils = require("config.utils")
local nmap = utils.nmap
local desc = utils.desc

desc("<leader>f", "[F]inder")

local fzf_lua = require("fzf-lua")
fzf_lua.setup {
    "fzf-tmux",
    file_icon_padding = " ",
    fzf_opts = {
        ["--border"] = "sharp",
        ["--preview-window"] = "border-sharp"
    },
    grep = {
        prompt = 'Grep❯ ',
        rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
    },
    -- FIXME: wait for fix for https://github.com/mfussenegger/nvim-jdtls/issues/608
    lsp = {
        code_actions = {
            previewer = false
        }
    },
}
fzf_lua.register_ui_select()

-- https://github.com/ibhagwan/fzf-lua/issues/602
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

nmap("<leader>fg", fzf_lua.grep_project, "[F]ind [G]rep")
nmap("<leader>fG", function()
    fzf_lua.grep_project({
        cmd = "git grep --line-number --column --color=always",
    })
end, "[F]ind Git [G]rep")
nmap("<leader>ff", fzf_lua.files, "[F]ind [F]iles")
nmap("<leader>fF", fzf_lua.git_files, "[F]ind Git [F]iles")
nmap("<leader>fa", fzf_lua.commands, "[F]ind [A]ctions")
nmap("<leader>fc", fzf_lua.git_bcommits, "[F]ind [C]ommits")
nmap("<leader>fC", fzf_lua.git_commits, "[F]ind All [C]ommits")
nmap("<leader>fb", fzf_lua.buffers, "[F]ind [B]uffers")
nmap("<leader>fh", fzf_lua.oldfiles, "[F]ind [H]istory")
nmap("<leader>fk", fzf_lua.keymaps, "[F]ind [K]eymaps")
