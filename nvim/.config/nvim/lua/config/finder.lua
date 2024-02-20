local utils = require('config.utils')
local au = utils.au
local nmap = utils.nmap
local desc = utils.desc

desc('<leader>f', '[F]inder')

local fzf_lua = require('fzf-lua')
fzf_lua.setup({
    'default',
    file_icon_padding = ' ',
    winopts = {
        border = "none",
        width = 1,
        height = 1
    },
    fzf_opts = {
        ['--info'] = false,
        ['--border'] = false,
        ['--preview-window'] = false,
    },
    files = {
        fzf_opts = {
            ['--info'] = false,
        },
    },
    grep = {
        prompt = 'Grep❯ ',
        rg_opts = '--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
        fzf_opts = {
            ['--info'] = false,
        },
    },
    lsp = {
        code_actions = {
            -- FIXME: wait for fix for https://github.com/mfussenegger/nvim-jdtls/issues/608
            previewer = false,
            winopts = {
                width = 0.6,
                height = 0.3
            },
        },
    },
    dap = {
        configurations = {
            winopts = {
                width = 0.6,
                height = 0.3
            },
        },
    },
})
fzf_lua.register_ui_select()

-- https://github.com/ibhagwan/fzf-lua/issues/602
vim.lsp.handlers['textDocument/codeAction'] = fzf_lua.lsp_code_actions
vim.lsp.handlers['textDocument/definition'] = fzf_lua.lsp_definitions
vim.lsp.handlers['textDocument/declaration'] = fzf_lua.lsp_declarations
vim.lsp.handlers['textDocument/typeDefinition'] = fzf_lua.lsp_typedefs
vim.lsp.handlers['textDocument/implementation'] = fzf_lua.lsp_implementations
vim.lsp.handlers['textDocument/references'] = fzf_lua.lsp_references
vim.lsp.handlers['textDocument/documentSymbol'] = fzf_lua.lsp_document_symbols
vim.lsp.handlers['workspace/symbol'] = fzf_lua.lsp_workspace_symbols
vim.lsp.handlers['callHierarchy/incomingCalls'] = fzf_lua.lsp_incoming_calls
vim.lsp.handlers['callHierarchy/outgoingCalls'] = fzf_lua.lsp_outgoing_calls

nmap('<leader>fg', fzf_lua.grep_project, '[F]ind [G]rep')
nmap('<leader>fG', function()
    fzf_lua.grep_project({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, '[F]ind Git [G]rep')
nmap('<leader>ff', fzf_lua.files, '[F]ind [F]iles')
nmap('<leader>fF', fzf_lua.git_files, '[F]ind Git [F]iles')
nmap('<leader>fa', fzf_lua.commands, '[F]ind [A]ctions')
nmap('<leader>fc', fzf_lua.git_bcommits, '[F]ind [C]ommits')
nmap('<leader>fC', fzf_lua.git_commits, '[F]ind All [C]ommits')
nmap('<leader>fb', fzf_lua.buffers, '[F]ind [B]uffers')
nmap('<leader>fh', fzf_lua.oldfiles, '[F]ind [H]istory')
nmap('<leader>fk', fzf_lua.keymaps, '[F]ind [K]eymaps')

-- Set as file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local loaded_buffs = {}
au('BufEnter', {
    pattern = "*",
    callback = function(args)
        if vim.bo[args.buf].filetype == "netrw" then
            return
        end
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if vim.fn.isdirectory(bufname) == 0 then
            return
        end

        -- prevents reopening of file-browser if exiting without selecting a file
        if loaded_buffs[bufname] then
            return
        end

        loaded_buffs[bufname] = true

        -- ensure no buffers remain with the directory name
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = args.buf })
        vim.api.nvim_set_option_value("buflisted", false, { buf = args.buf })

        vim.schedule(function()
            fzf_lua.files({
                cwd = vim.fn.expand "%:p:h",
            })
        end)
    end
})

au('BufLeave', {
    pattern = "*",
    callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if vim.fn.isdirectory(bufname) == 0 then
            return
        end
        loaded_buffs[bufname] = nil
    end
})

nmap('-', function()
    fzf_lua.files({
        cwd = vim.fn.expand "%:p:h",
    })
end, '[F]ind [F]iles in current directory')
