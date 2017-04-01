" Deoplete plugin integration
let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
let g:deoplete#omni#input_patterns.typescript = ['[^. \t0-9]\.\w*']

" Tsuquyomi and synstatic integration
let g:tsuquyomi_disable_quickfix = 1
let g:syntastic_typescript_checkers = ['tsuquyomi']
