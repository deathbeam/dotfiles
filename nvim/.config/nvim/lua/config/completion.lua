-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Buffer autocompletion
require('mini.completion').setup {
    window = {
        info = {
            border = 'single',
        },
        signature = {
            border = 'single',
        },
    }
}

vim.o.completeopt = 'menu,menuone,noinsert,preview'
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() ~= 0 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-y>", true, true, true), "n", true)
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
    end
end, { expr = true })

-- Cmdline autocompletion
local wilder = require('wilder')
wilder.setup {
    modes = {':', '/', '?'},
    next_key = '<C-n>',
    previous_key = '<C-p>',
    accept_key = '<Tab>',
}
wilder.set_option('renderer', wilder.popupmenu_renderer({
    -- highlighter applies highlighting to the candidates
    highlighter = wilder.basic_highlighter(),
}))
