require('nvim-treesitter.configs').setup({
    ensure_installed = vim.tbl_values(vim.tbl_flatten(vim.tbl_map(
        function(server)
            return server.language
        end,
        vim.tbl_filter(function(server)
            return server.language
        end, require('config.languages'))
    ))),
    sync_install = true,
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            include_surrounding_whitespace = true,
            keymaps = {
                ['am'] = '@function.outer',
                ['im'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['ab'] = '@block.outer',
                ['ib'] = '@block.inner',
                ['as'] = '@statement.outer',
                ['is'] = '@statement.inner',
                ['ax'] = '@attribute.outer',
                ['ix'] = '@attribute.inner',
                ['i/'] = '@comment.inner',
                ['a/'] = '@comment.outer',
                ['i#'] = '@comment.inner',
                ['a#'] = '@comment.outer',
                ['i*'] = '@comment.inner',
                ['a*'] = '@comment.outer',
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                [']m'] = '@function.outer',
                [']c'] = '@class.outer',
                [']a'] = '@parameter.outer',
                [']b'] = '@block.outer',
                [']s'] = '@statement.outer',
                [']x'] = '@attribute.outer',
                [']/'] = '@comment.outer',
                [']#'] = '@comment.outer',
                [']*'] = '@comment.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']C'] = '@class.outer',
                [']A'] = '@parameter.outer',
                [']B'] = '@block.outer',
                [']S'] = '@statement.outer',
                [']X'] = '@attribute.outer',
                [']?'] = '@comment.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[c'] = '@class.outer',
                ['[a'] = '@parameter.outer',
                ['[b'] = '@block.outer',
                ['[s'] = '@statement.outer',
                ['[x'] = '@attribute.outer',
                ['[/'] = '@comment.outer',
                ['[#'] = '@comment.outer',
                ['[*'] = '@comment.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[C'] = '@class.outer',
                ['[A'] = '@parameter.outer',
                ['[B'] = '@block.outer',
                ['[S'] = '@statement.outer',
                ['[X'] = '@attribute.outer',
                ['[?'] = '@comment.outer',
            },
        },
    },
})

vim.cmd([[
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
]])
