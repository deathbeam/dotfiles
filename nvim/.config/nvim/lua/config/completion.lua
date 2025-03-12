-- Enable popup menu and set options
if vim.fn.has('nvim-0.11.0') == 1 then
    vim.o.completeopt = 'menuone,noinsert,fuzzy,popup'
    vim.o.completeitemalign = 'kind,abbr,menu'
else
    vim.o.completeopt = 'menuone,noinsert,popup'
end

-- Tab to accept
vim.keymap.set('i', '<Tab>', function()
    return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<Tab>'
end, { expr = true, replace_keycodes = true })
