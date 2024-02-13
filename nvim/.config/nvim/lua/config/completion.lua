-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Buffer autocompletion
require('mini.completion').setup {
    fallback_action = function() end,
    window = {
        info = {
            border = 'single',
        },
        signature = {
            border = 'single',
        },
    }
}

vim.o.completeopt = 'menuone,noinsert'
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() ~= 0 then
        return vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
    else
        return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
    end
end, { expr = true })

-- Cmdline completion
require('config.cmdline-completion').setup()
