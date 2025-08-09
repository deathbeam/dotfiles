-- Enable popup menu and set options
vim.o.completeopt = 'menuone,noinsert,fuzzy,popup'
vim.o.completeitemalign = 'kind,abbr,menu'
vim.o.autocomplete = true
vim.o.complete = '.,o'

-- Tab to accept
vim.keymap.set('i', '<Tab>', function()
    return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<Tab>'
end, { expr = true, replace_keycodes = true })
