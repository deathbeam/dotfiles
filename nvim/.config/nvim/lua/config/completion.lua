local icons = require('config.icons')

-- Enable popup menu and set options
vim.o.completeopt = 'menuone,noselect,noinsert,fuzzy,popup'
vim.o.completeitemalign = 'kind,abbr,menu'

-- Tab to accept
vim.keymap.set('i', '<Tab>', function()
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info().selected == -1 then
            return '<C-n><C-y>'  -- Select first item and confirm
        else
            return '<C-y>'       -- Confirm current selection
        end
    end

    return '<Tab>'              -- Normal tab behavior if no popup
end, { expr = true, replace_keycodes = true, noremap = true })

require('autocomplete.signature').setup({
    border = 'single',
})

require('autocomplete.buffer').setup({
    border = 'single',
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
