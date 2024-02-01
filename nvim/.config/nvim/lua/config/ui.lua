local base16 = require("base16-colorscheme")
vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Adjust colors",
    callback = function()
        local base0A = base16.colors.base0A
        local base0D = base16.colors.base0D
        local base00 = base16.colors.base00
        local base03 = base16.colors.base03
        local base0B = base16.colors.base0B
        local base0E = base16.colors.base0E

        vim.api.nvim_set_hl(0, "StatusLine", { fg = base00, underline = true })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = base03, underline = true, })
        vim.api.nvim_set_hl(0, "VertSplit", { fg = base03 })
        vim.api.nvim_set_hl(0, "User1", { underline = true, bg = base0D, fg = base00 })
        vim.api.nvim_set_hl(0, "User2", { underline = true, fg = base0D })
        vim.api.nvim_set_hl(0, "User3", { underline = true, fg = base0B })
        vim.api.nvim_set_hl(0, "User4", { underline = true, fg = base0E })
        vim.api.nvim_set_hl(0, "User5", { underline = true, fg = base0A })
    end
})
base16.load_from_shell()

require("nvim-web-devicons").setup()
require("eyeliner").setup { highlight_on_key = true, dim = true }
require("fidget").setup { notification = { override_vim_notify = not vim.tbl_isempty(vim.api.nvim_list_uis()) } }

local function icon(sign, len)
    sign = sign or {}
    len = len or 2
    local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
    text = text .. string.rep(" ", len - vim.fn.strchars(text))
    return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

local function get_sign(buf, lnum)
    local signs = {}
    local extmarks = vim.api.nvim_buf_get_extmarks(
        buf,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true, type = "sign" }
    )
    for _, extmark in pairs(extmarks) do
        signs[#signs + 1] = {
            name = extmark[4].sign_hl_group or "",
            text = extmark[4].sign_text,
            texthl = extmark[4].sign_hl_group,
            priority = extmark[4].priority,
        }
    end

    table.sort(signs, function(a, b)
        return (a.priority or 0) < (b.priority or 0)
    end)

    if signs then
        return signs[#signs]
    end

    return nil
end

local function get_mark(buf, lnum)
    local marks = vim.fn.getmarklist(buf)
    vim.list_extend(marks, vim.fn.getmarklist())
    for _, mark in ipairs(marks) do
        if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
            return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
        end
    end
end

function StatusColumn()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)
    local show_signs = vim.wo[win].signcolumn ~= "no"

    local components = { "", "", "" } -- left, middle, right

    if show_signs then
        local sign = get_sign(buf, vim.v.lnum)

        local fold
        vim.api.nvim_win_call(win, function()
            if vim.fn.foldclosed(vim.v.lnum) >= 0 then
                fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "FoldColumn" }
            elseif vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1) then
                fold = { text = vim.opt.fillchars:get().foldopen or "" }
            end
        end)

        local mark = get_mark(buf, vim.v.lnum)
        if vim.v.virtnum ~= 0 then
            sign = nil
        else
            sign = sign or mark or fold
        end

        components[2] = icon(sign)
    end

    local is_num = vim.wo[win].number
    local is_relnum = vim.wo[win].relativenumber
    if (is_num or is_relnum) and vim.v.virtnum == 0 then
        if vim.v.relnum == 0 then
            components[1] = is_num and "%l" or "%r" -- the current line
        else
            components[1] = is_relnum and "%r" or "%l" -- other lines
        end
    end

    components[1] = "%=" .. components[1] .. " " -- right align
    return table.concat(components)
end

vim.opt.statuscolumn = [[%!v:lua.StatusColumn()]]

function StatusLineActive()
    return table.concat {
        -- color 1
        [[%1*]],
        -- file format
        [[ %{&ff}]],
        -- file type
        [[%y]],
        -- full path
        [[ %<%F]],
        -- modified flag 
        [[ %m]],
        -- color 2
        [[%2*]],
        -- left/right separator
        [[%=]],
        -- color 3
        [[%3*]],
        -- cursor info
        [[%l/%L-%v\ 0x%04B]]
    }
end

function StatusLineInactive()
    return table.concat {
        -- file format
        [[ %{&ff}]],
        -- file type
        [[%y]],
        -- full path
        [[ %<%F]],
        -- modified flag 
        [[ %m]],
    }
end

vim.cmd [[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.StatusLineActive()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.StatusLineInactive()
  augroup END
]]
