local icons = require('config.icons')

-- Enable popup menu and set options
vim.o.completeopt = 'menu,noselect,noinsert,fuzzy,popup'

-- Tab to accept
vim.keymap.set('i', '<Tab>', function()
    return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<Tab>'
end, { expr = true, replace_keycodes = true })

require('autocomplete.signature').setup({
    border = 'single',
})

require('autocomplete.buffer').setup({
    entry_mapper = function(entry)
        local kind = entry.kind
        local icon = icons.kinds[kind]
        entry.kind = icon and icon .. ' ' .. kind or kind
        return entry
    end,
})

require('autocomplete.cmd').setup({
    mappings = {
        accept = '<Tab>',
    },
    close_on_done = false,
})
