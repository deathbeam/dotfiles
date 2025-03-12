local function icon(sign, len)
    sign = sign or {}
    len = len or 2
    local text = vim.fn.strcharpart(sign.text or '', 0, len)
    text = text .. string.rep(' ', len - vim.fn.strchars(text))
    return sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*') or text
end

local function get_sign(buf, lnum)
    local signs = {}
    local extmarks = vim.api.nvim_buf_get_extmarks(
        buf,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true, type = 'sign' }
    )
    for _, extmark in pairs(extmarks) do
        signs[#signs + 1] = {
            name = extmark[4].sign_hl_group or '',
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
        if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match('[a-zA-Z]') then
            return { text = mark.mark:sub(2), texthl = 'DiagnosticHint' }
        end
    end
end

local function get_fold(win, lnum)
    local fold = nil
    vim.api.nvim_win_call(win, function()
        if vim.fn.foldclosed(lnum) >= 0 then
            fold = { text = vim.opt.fillchars:get().foldclose, texthl = 'FoldColumn' }
        elseif vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1) then
            fold = { text = vim.opt.fillchars:get().foldopen }
        end
    end)
    return fold
end

function StatusColumn()
    local components = { '', '', '' } -- left, middle, right

    local win = vim.g.statusline_winid
    local show_signs = vim.wo[win].signcolumn ~= 'no'

    -- Line numbers
    components[1] = '%=%l'

    -- Merged signs
    if show_signs and vim.v.virtnum == 0 then
        local buf = vim.api.nvim_win_get_buf(win)
        local sign = get_sign(buf, vim.v.lnum)
        local fold = get_fold(win, vim.v.lnum)
        local mark = get_mark(buf, vim.v.lnum)
        components[2] = icon(sign or mark or fold)
    end

    return table.concat(components)
end

vim.opt.statuscolumn = [[%!v:lua.StatusColumn()]]
