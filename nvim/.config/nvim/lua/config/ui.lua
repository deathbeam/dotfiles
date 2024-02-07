-- Set base16 colorscheme
local base16 = require("base16-colorscheme")
vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Adjust colors",
    callback = function()
        local base0D = base16.colors.base0D
        local base00 = base16.colors.base00
        local base03 = base16.colors.base03
        local base0B = base16.colors.base0B

        vim.api.nvim_set_hl(0, "StatusLine", { fg = base00, underline = true })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = base03, underline = true, })
        vim.api.nvim_set_hl(0, "LineNr", { fg = base03 })
        vim.api.nvim_set_hl(0, "VertSplit", { fg = base03 })
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = base03 })
        vim.api.nvim_set_hl(0, "User1", { underline = false, bg = base0D, fg = base00 })
        vim.api.nvim_set_hl(0, "User2", { underline = true, fg = base0D })
        vim.api.nvim_set_hl(0, "User3", { underline = false, bg = base0B, fg = base00 })
    end
})
base16.load_from_shell()

-- Set colorcolumn to textwidth
vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Set colorcolumn",
    callback = function()
        vim.opt.colorcolumn = "" .. vim.opt.textwidth:get()
    end
})

-- Load icons
require("nvim-web-devicons").setup()

-- File browser
require("oil").setup {
    view_options = {
        show_hidden = true
    }
}

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
