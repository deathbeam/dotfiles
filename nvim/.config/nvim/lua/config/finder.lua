local utils = require('config.utils')
local nmap = utils.nmap
local nvmap = utils.nvmap
local desc = utils.desc

desc('<leader>f', 'Find')

local fzf_lua = require('fzf-lua')
fzf_lua.setup({
    'fzf-tmux',
    file_icon_padding = ' ',
    fzf_opts = {
        ['--info'] = false,
        ['--border'] = false,
        ['--preview-window'] = 'border-sharp',
        ['--tmux'] = '100%,100%',
    },
    defaults = {
        formatter = 'path.filename_first',
        multiline = 1,
    },
    grep = {
        rg_opts = ' --hidden --glob "!.git/" --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
        prompt = 'Grep❯ ',
        no_column_hide = true,
    },
    lsp = {
        code_actions = {
            fzf_opts = {
                ['--tmux'] = 'bottom,50%',
            },
        },
    },
    dap = {
        configurations = {
            fzf_opts = {
                ['--tmux'] = 'bottom,50%',
            },
        },
    },
})

fzf_lua.register_ui_select({
    fzf_opts = {
        ['--tmux'] = 'bottom,50%',
    },
})

-- https://github.com/ibhagwan/fzf-lua/issues/602
local function w(fn)
    return function(...)
        return fn({
            ignore_current_line = true,
            jump1 = true,
            includeDeclaration = false,
        }, ...)
    end
end

-- Doesnt actually work because of https://github.com/neovim/neovim/pull/30877/files
-- vim.lsp.handlers['textDocument/definition'] = w(fzf_lua.lsp_definitions)
-- vim.lsp.handlers['textDocument/declaration'] = w(fzf_lua.lsp_declarations)
-- vim.lsp.handlers['textDocument/typeDefinition'] = w(fzf_lua.lsp_typedefs)
-- vim.lsp.handlers['textDocument/implementation'] = w(fzf_lua.lsp_implementations)
-- vim.lsp.handlers['textDocument/references'] = w(fzf_lua.lsp_references)

nmap('gd', w(fzf_lua.lsp_definitions), 'Goto Definition')
nmap('gD', w(fzf_lua.lsp_declarations), 'Goto Declaration')
nmap('gi', w(fzf_lua.lsp_implementations), 'Goto Implementation')
nmap('gy', w(fzf_lua.lsp_typedefs), 'Goto Type Definition')
nmap('gr', w(fzf_lua.lsp_references), 'Goto References')

vim.lsp.handlers['textDocument/codeAction'] = w(fzf_lua.lsp_code_actions)
vim.lsp.handlers['textDocument/documentSymbol'] = w(fzf_lua.lsp_document_symbols)
vim.lsp.handlers['workspace/symbol'] = w(fzf_lua.lsp_workspace_symbols)
vim.lsp.handlers['callHierarchy/incomingCalls'] = w(fzf_lua.lsp_incoming_calls)
vim.lsp.handlers['callHierarchy/outgoingCalls'] = w(fzf_lua.lsp_outgoing_calls)

nmap('<leader>fg', fzf_lua.live_grep_glob, 'Find Grep')
nmap('<leader>fG', function()
    fzf_lua.live_grep_glob({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, 'Find Git Grep')
nmap('<leader>fr', fzf_lua.resume, 'Find Resume')
nmap('<leader>ff', fzf_lua.files, 'Find Files')
nmap('<leader>fF', fzf_lua.git_files, 'Find Git Files')
nmap('<leader>fa', fzf_lua.commands, 'Find Actions')
nvmap('<leader>fc', fzf_lua.git_bcommits, 'Find Commits')
nmap('<leader>fC', fzf_lua.git_commits, 'Find All Commits')
nmap('<leader>fB', fzf_lua.git_blame, 'Find Blame')
nmap('<leader>fb', fzf_lua.buffers, 'Find Buffers')
nmap('<leader>fh', fzf_lua.oldfiles, 'Find History')
nmap('<leader>fk', fzf_lua.keymaps, 'Find Keymaps')
nmap('<leader>fq', fzf_lua.quickfix, 'Find Quickfix')
nmap('<leader>f?', fzf_lua.helptags, 'Find Help')
nmap('<leader>fj', fzf_lua.jumps, 'Find Jumps')
nmap('<leader>fm', fzf_lua.marks, 'Find Marks')
nmap('<leader>fd', fzf_lua.lsp_document_diagnostics, 'Find Diagnostics')
nmap('<leader>fD', fzf_lua.lsp_workspace_diagnostics, 'Find all Diagnostics')
nmap('<leader>fs', fzf_lua.lsp_document_symbols, 'Find Symbols')
nmap('<leader>fS', fzf_lua.lsp_live_workspace_symbols, 'Find all Symbols')
