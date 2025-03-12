local layout = {
    left_win = nil,
    right_win = nil,
}

-- Set up a consistent layout with two diff windows and quickfix at bottom
local function setup_layout()
    if layout.left_win and vim.api.nvim_win_is_valid(layout.left_win) then
        return false
    end

    -- Save current window as left window
    layout.left_win = vim.api.nvim_get_current_win()

    -- Create right window
    vim.cmd('vsplit')
    layout.right_win = vim.api.nvim_get_current_win()
end

local function edit_in(winnr, file)
    vim.api.nvim_win_call(winnr, function()
        local current = vim.fs.abspath(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winnr)))

        -- Check if the current buffer is already the target file
        if current == (file and vim.fs.abspath(file) or '') then
            return
        end

        if file then
            -- Read the file if it exists
            vim.cmd('edit ' .. vim.fn.fnameescape(file))
        else
            -- Create an empty buffer for added/removed files
            vim.cmd('enew')
            vim.bo.buftype = 'nofile'
            vim.bo.bufhidden = 'wipe'
            vim.bo.swapfile = false
        end
    end)
end

local function diff_files(left_file, right_file)
    setup_layout()

    edit_in(layout.left_win, left_file)
    edit_in(layout.right_win, right_file)

    vim.cmd('diffoff!')
    vim.api.nvim_win_call(layout.left_win, vim.cmd.diffthis)
    vim.api.nvim_win_call(layout.right_win, vim.cmd.diffthis)
end

local function diff_directories(left_dir, right_dir)
    setup_layout()

    -- Create a map of all relative paths
    local all_paths = {}

    -- Process left files
    local left_files = vim.fs.find(function()
        return true
    end, { limit = math.huge, path = left_dir, follow = false })
    for _, full_path in ipairs(left_files) do
        local rel_path = full_path:sub(#left_dir + 1)
        full_path = vim.fn.resolve(full_path)

        if vim.fn.isdirectory(full_path) == 0 then
            all_paths[rel_path] = all_paths[rel_path] or { left = nil, right = nil }
            all_paths[rel_path].left = full_path
        end
    end

    -- Process right files
    local right_files = vim.fs.find(function()
        return true
    end, { limit = math.huge, path = right_dir, follow = false })
    for _, full_path in ipairs(right_files) do
        local rel_path = full_path:sub(#right_dir + 1)
        full_path = vim.fn.resolve(full_path)

        if vim.fn.isdirectory(full_path) == 0 then
            all_paths[rel_path] = all_paths[rel_path] or { left = nil, right = nil }
            all_paths[rel_path].right = full_path
        end
    end

    -- Convert to quickfix entries
    local qf_entries = {}
    for rel_path, files in pairs(all_paths) do
        local status = 'M' -- Modified (both files exist)
        if not files.left then
            status = 'A' -- Added (only in right)
        elseif not files.right then
            status = 'D' -- Deleted (only in left)
        end

        table.insert(qf_entries, {
            filename = files.right or files.left,
            text = status .. ' ' .. rel_path,
            user_data = {
                diff = true,
                rel = rel_path,
                left = files.left,
                right = files.right,
            },
        })
    end

    -- Sort entries by filename for consistency
    table.sort(qf_entries, function(a, b)
        return a.user_data.rel < b.user_data.rel
    end)

    vim.fn.setqflist({}, 'r', {
        ---@diagnostic disable-next-line: assign-type-mismatch
        nr = '$',
        title = 'DiffTool',
        items = qf_entries,
    })

    vim.cmd('botright copen')
    vim.cmd.cfirst()
end

vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = '*',
    callback = function(args)
        local qf_info = vim.fn.getqflist({ idx = 0 })
        local qf_list = vim.fn.getqflist()
        local entry = qf_list[qf_info.idx]

        -- Check if the entry is a diff entry
        if not entry or not entry.user_data or not entry.user_data.diff or args.buf ~= entry.bufnr then
            return
        end

        vim.schedule(function()
            diff_files(entry.user_data.left, entry.user_data.right)
        end)
    end,
})

vim.api.nvim_create_user_command('DiffTool', function(opts)
    if #opts.fargs >= 2 then
        local left = opts.fargs[1]
        local right = opts.fargs[2]

        if vim.fn.isdirectory(left) == 1 and vim.fn.isdirectory(right) == 1 then
            diff_directories(left, right)
        elseif vim.fn.filereadable(left) == 1 and vim.fn.filereadable(right) == 1 then
            diff_files(left, right)
        else
            vim.notify('Both arguments must be files or directories', vim.log.levels.ERROR)
        end
    else
        vim.notify('Usage: DiffTool <left> <right>', vim.log.levels.ERROR)
    end
end, { nargs = '*' })
