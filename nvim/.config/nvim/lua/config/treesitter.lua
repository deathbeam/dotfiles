local packages = vim.iter(require('config.languages'))
    :map(function(server)
        return server.treesitter
    end)
    :filter(function(server)
        return server
    end)
    :flatten()
    :totable()

vim.api.nvim_create_user_command('TSUpdateSync', function()
    vim.notify('Syncing treesitter parsers...', vim.log.levels.INFO)
    local ts = require('nvim-treesitter')
    local installed = ts.get_installed()
    local to_install = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
    end, packages)
    local to_uninstall = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(packages, lang)
    end, installed)
    if #to_uninstall > 0 then
        ts.uninstall(to_uninstall):wait()
    end
    if #to_install > 0 then
        ts.install(to_install):wait()
    end

    ts.update():wait()
    vim.notify('Successfully synced ' .. #packages .. ' parsers.', vim.log.levels.INFO)
end, {})

local TS_DISABLE_THRESHOLD = 8000

--- @param buf integer
--- @return boolean
local function should_disable_treesitter(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    local line_count = vim.api.nvim_buf_line_count(buf)
    return line_count >= TS_DISABLE_THRESHOLD
end

--- @param buf integer
local function disable_treesitter(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local ok = pcall(vim.treesitter.stop, buf)
    if ok then
        vim.bo[buf].syntax = 'on'
        vim.notify('Treesitter disabled (' .. vim.api.nvim_buf_line_count(buf) .. ' lines)', vim.log.levels.WARN)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function(ev)
        local ft = ev.match
        local buf = ev.buf

        -- Disable treesitter if buffer exceeds threshold
        if should_disable_treesitter(buf) then
            disable_treesitter(buf)
            return
        end

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang or not vim.treesitter.language.add(lang) then
            return
        end

        vim.notify('Starting treesitter for ' .. lang, vim.log.levels.INFO)
        vim.treesitter.start(buf)
        vim.bo[buf].syntax = 'on'

        -- NOTE: indent forces a re-parse, which negates the benefit of async
        -- parsing see https://github.com/nvim-treesitter/nvim-treesitter/issues/7840
        -- if lang and vim.treesitter.query.get(lang, 'folds') then
        --     vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- end
        --
        -- if lang and vim.treesitter.query.get(lang, 'indents') then
        --     vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        -- end

        -- Treehopper mappings
        vim.cmd([[
            omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
            xnoremap <silent> m :lua require('tsht').nodes()<CR>
        ]])
    end,
})

-- Monitor buffer size and disable treesitter if it grows past threshold
local ts_size_group = vim.api.nvim_create_augroup('TreesitterSizeCheck', { clear = true })
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufWritePost' }, {
    group = ts_size_group,
    pattern = '*',
    callback = function(ev)
        local buf = ev.buf
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        -- Only check buffers that have treesitter running
        -- vim.treesitter.highlighter.active[buf] is set when TS is active
        if not vim.treesitter.highlighter.active[buf] then
            return
        end
        if should_disable_treesitter(buf) then
            disable_treesitter(buf)
        end
    end,
})

vim.treesitter.language.register('bash', 'zsh')
