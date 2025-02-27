local config = {
    dir = vim.fn.expand('~/vimwiki'),
}

local icons = require('config.icons')
local utils = require('config.utils')
local nmap = utils.nmap
local desc = utils.desc

desc('<leader>w', 'Wiki', icons.ui.Wiki)

local Wiki = {}

-- Open today's diary entry
function Wiki.today()
    local today = os.date('%Y-%m-%d')
    local file = config.dir .. '/diary/' .. today .. '.md'
    vim.cmd('edit ' .. file)
end

-- List diary entries using fzf-lua
function Wiki.list_diary()
    require('fzf-lua').files({
        prompt = 'Diary > ',
        cwd = config.dir .. '/diary',
        cmd = 'ls -1 | sort -r', -- Sort by date
        file_ignore_patterns = {
            '^[^0-9].*', -- Only show date-formatted files
        },
    })
end

-- List wiki entries using fzf-lua
function Wiki.list_wiki()
    require('fzf-lua').files({
        prompt = 'Wiki > ',
        cwd = config.dir,
        file_ignore_patterns = {
            'diary/.*', -- Exclude diary directory
        },
    })
end

-- Create new wiki entry
function Wiki.new(title)
    if not title then
        title = vim.fn.input('Wiki title: ')
    end
    if title ~= '' then
        local filename = title:gsub(' ', '_') .. '.md'
        vim.cmd.edit(config.dir .. '/' .. filename)
    end
end

nmap('<leader>wt', Wiki.today, 'Wiki Today')
nmap('<leader>wd', Wiki.list_diary, 'Wiki Diary List')
nmap('<leader>ww', Wiki.list_wiki, 'Wiki List')
nmap('<leader>wn', Wiki.new, 'Wiki New')

return Wiki
