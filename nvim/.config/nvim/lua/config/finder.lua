local utils = require('config.utils')
local au = utils.au
local nmap = utils.nmap
local desc = utils.desc

desc('<leader>f', 'Find')

local fzf_lua = require('fzf-lua')
fzf_lua.setup({
    'fzf-tmux',
    file_icon_padding = ' ',
    fzf_opts = {
        ['--info'] = false,
        ['--border'] = false,
        ['--preview-window'] = false,
    },
    fzf_tmux_opts = {
        ['-d'] = '100%',
    },
    previewers = {
        codeaction_native = {
            pager = [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]],
        },
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
            fzf_tmux_opts = {
                ['-d'] = '45%',
            },
        },
    },
    dap = {
        configurations = {
            fzf_tmux_opts = {
                ['-d'] = '45%',
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

nmap('<leader>fg', fzf_lua.grep_project, 'Find Grep')
nmap('<leader>fG', function()
    fzf_lua.grep_project({
        prompt = 'GitGrep❯ ',
        cmd = 'git grep --line-number --column --color=always',
    })
end, 'Find Git Grep')
nmap('<leader>ff', fzf_lua.files, 'Find Files')
nmap('<leader>fF', fzf_lua.git_files, 'Find Git Files')
nmap('<leader>fa', fzf_lua.commands, 'Find Actions')
nmap('<leader>fc', fzf_lua.git_bcommits, 'Find Commits')
nmap('<leader>fC', fzf_lua.git_commits, 'Find All Commits')
nmap('<leader>fb', fzf_lua.buffers, 'Find Buffers')
nmap('<leader>fh', fzf_lua.oldfiles, 'Find History')
nmap('<leader>fk', fzf_lua.keymaps, 'Find Keymaps')

-- Disable netrw
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- local loaded_buffs = {}

-- local function open_files()
--     fzf_lua.files({
--         cwd = vim.fn.expand('%:p:h'),
--     })
-- end

-- -- Use - for opening explorer in current directory
-- nmap('-', open_files)

-- -- Open fzf in the directory when opening a directory buffer
-- au('BufEnter', {
--     pattern = '*',
--     callback = function(args)
--         -- If netrw is enabled just keep it, but it should be disabled
--         if vim.bo[args.buf].filetype == 'netrw' then
--             return
--         end

--         -- Get buffer name and check if it's a directory
--         local bufname = vim.api.nvim_buf_get_name(args.buf)
--         if vim.fn.isdirectory(bufname) == 0 then
--             return
--         end

--         -- Prevent reopening the explorer after it's been closed
--         if loaded_buffs[bufname] then
--             return
--         end
--         loaded_buffs[bufname] = true

--         -- Do not list directory buffer and wipe it on leave
--         vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = args.buf })
--         vim.api.nvim_set_option_value('buflisted', false, { buf = args.buf })

--         -- Open fzf in the directory
--         vim.schedule(open_files)
--     end,
-- })

-- -- This makes sure that the explorer will open again after opening same buffer again
-- au('BufLeave', {
--     pattern = '*',
--     callback = function(args)
--         local bufname = vim.api.nvim_buf_get_name(args.buf)
--         if vim.fn.isdirectory(bufname) == 0 then
--             return
--         end
--         loaded_buffs[bufname] = nil
--     end,
-- })
