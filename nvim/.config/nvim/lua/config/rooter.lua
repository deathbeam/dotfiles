local au = require("config.utils").au
local root_cache = {}

local function find_root(markers)
    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local dirname = vim.fn.fnamemodify(bufname, ':p:h'):gsub("oil://", "")
    if root_cache[dirname] then
        return root_cache[dirname]
    end

    local getparent = function(p)
        return vim.fn.fnamemodify(p, ':h')
    end
    while getparent(dirname) ~= dirname do
        for _, marker in ipairs(markers) do
            if vim.loop.fs_stat(vim.fs.joinpath(dirname, marker)) then
                root_cache[dirname] = dirname
                return dirname
            end
        end
        dirname = getparent(dirname)
    end
end

-- Find root directory
local root_patterns = {
    '.git',
    '.git/',
    '_darcs/',
    '.hg/',
    '.bzr/',
    '.svn/',
    '.editorconfig',
    'Makefile',
    '.pylintrc',
    'requirements.txt',
    'setup.py',
    'package.json',
    'mvnw',
    'gradlew',
}

au({ "VimEnter", "BufEnter" }, {
    desc = "Find root directory",
    pattern = "*",
    nested = true,
    callback = function()
        local root_dir = find_root(root_patterns)
        if root_dir then
            vim.api.nvim_set_current_dir(root_dir)
        end
    end,
})
