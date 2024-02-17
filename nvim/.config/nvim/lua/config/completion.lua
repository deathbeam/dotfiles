-- Copilot autosuggestions
require('copilot').setup({
  panel = {
    enabled = false,
  },
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<S-Tab>",
      next = false,
      prev = false,
      dismiss = false,
    },
  },
})

-- Completion
vim.o.completeopt = 'menuone,noinsert,popup'
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() ~= 0 then
        return "<C-y>"
    else
        return "<Tab>"
    end
end, { expr = true, replace_keycodes = true })

require('autocomplete.signature').setup { border = "single" }
require('autocomplete.lsp').setup {}
require('autocomplete.cmd').setup {
    close_on_done = false,
    mappings = {
        accept = "<Tab>",
    }
}
