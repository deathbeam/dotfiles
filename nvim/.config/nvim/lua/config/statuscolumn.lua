local icons = require("config.icons")
vim.opt.fillchars = { foldclose = icons.fold.Closed, foldopen = icons.fold.Open }

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

local function get_fold(lnum)
    if vim.fn.foldclosed(lnum) >= 0 then
        return { text = vim.opt.fillchars:get().foldclose, texthl = "FoldColumn" }
    elseif vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1) then
        return { text = vim.opt.fillchars:get().foldopen }
    end
end

function StatusColumn()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)
    local show_signs = vim.wo[win].signcolumn ~= "no"

    local components = { "", "", "" } -- left, middle, right

    if show_signs then
        local sign = get_sign(buf, vim.v.lnum)
        local fold = get_fold(vim.v.lnum)
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
