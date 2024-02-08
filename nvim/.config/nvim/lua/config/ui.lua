local utils = require("config.utils")
local au = utils.au
local nmap = utils.nmap

-- Set base16 colorscheme
vim.opt.termguicolors = true
local base16 = require("base16-colorscheme")
au("ColorScheme", {
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

-- Load icons
require("nvim-web-devicons").setup()

-- File browser
require("oil").setup {
    view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
            return name == ".."
        end,
    },
    keymaps = {
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = false,
        ["<C-p>"] = false,
        ["<C-c>"] = false,
        ["<C-l>"] = false,
    }
}
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Tmux bindings
require("tmux").setup {
    copy_sync = {
        enable = false
    }
}

-- Set colorcolumn to textwidth
au({ "BufEnter", "WinEnter" }, {
    desc = "Set colorcolumn",
    callback = function()
        vim.opt_local.colorcolumn = "" .. vim.opt_local.textwidth:get()
    end
})

-- Automatically rebalance windows on vim resize
au("VimResized", {
    desc = "Rebalance windows",
    callback = function()
        vim.cmd("wincmd =")
    end
})

-- Restore cursor position
au('BufRead', {
    desc = "Restore cursor position outer",
    callback = function(opts)
        au('BufWinEnter', {
            desc = "Restore cursor position inner",
            once = true,
            buffer = opts.buf,
            callback = function()
                local ft = vim.bo[opts.buf].filetype
                local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                if
                    not (ft:match('commit') and ft:match('rebase'))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                then
                    vim.api.nvim_feedkeys([[g`"]], 'nx', false)
                end
            end,
        })
    end,
})

-- Toggle zoom
local restore_zoom = {}
local function toggle_zoom(zoom)
    if restore_zoom.win and (zoom or restore_zoom.win ~= vim.fn.winnr()) then
        vim.cmd(restore_zoom.cmd)
        restore_zoom = {}
    elseif zoom then
        restore_zoom = { win = vim.fn.winnr(), cmd = vim.fn.winrestcmd() }
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-W>|<C-W>_", true, true, true), "n", true)
    end
end
au("WinEnter", {
    desc = "Restore zoom",
    callback = function()
        toggle_zoom(false)
    end
})
nmap("<leader>z", function() toggle_zoom(true) end, "Toggle [Z]oom")
