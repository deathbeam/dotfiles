-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Completion
vim.o.completeopt = 'menuone,noinsert,popup'
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() ~= 0 then
        return "<C-y>"
    else
        return "<Tab>"
    end
end, { expr = true, replace_keycodes = true })

require('config.completion.lsp').setup {
    window = {
        border = "single"
    },
}
require('config.completion.cmd').setup {
    close_on_done = false,
    mappings = {
        accept = "<Tab>",
    }
}
