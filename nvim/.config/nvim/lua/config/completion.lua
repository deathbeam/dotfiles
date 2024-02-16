-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Completion
vim.o.completeopt = 'menuone,noinsert,popup'
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() ~= 0 then
        return vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
    else
        return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
    end
end, { expr = true })

require('config.completion.lsp').setup {}
require('config.completion.cmd').setup {
    close_on_done = false,
    mappings = {
        accept = "<Tab>",
    }
}
