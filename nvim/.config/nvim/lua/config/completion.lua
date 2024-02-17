-- Copilot autosuggestions
require('copilot').setup({
    panel = {
        enabled = false,
    },
    suggestion = {
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
            accept = '<S-Tab>',
            next = false,
            prev = false,
            dismiss = false,
        },
    },
})

-- Enable popup menu and set options
vim.o.completeopt = 'menuone,noinsert,popup'

-- Tab to accept
vim.keymap.set('i', '<Tab>', function()
    return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<Tab>'
end, { expr = true, replace_keycodes = true })

-- Disable <CR> to accept (this really should be a mapping, so stupid)
vim.keymap.set('i', '<CR>', function()
    return vim.fn.pumvisible() ~= 0 and '<Esc>o' or '<CR>'
end, { expr = true, replace_keycodes = true })

require('autocomplete.signature').setup({ border = 'single' })
require('autocomplete.lsp').setup({})
require('autocomplete.cmd').setup({
    close_on_done = false,
    mappings = {
        accept = '<Tab>',
    },
})
