local icons = require('config.icons')

-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

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

require('autocomplete.signature').setup({
    border = 'single'
})

require('autocomplete.lsp').setup({
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
