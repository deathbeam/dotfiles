" Completor integration
let g:completor_typescript_omni_trigger = '(\w+|[^\. \t0-9]+\.\w*)$'

" Tsuquyomi and syntastic integration
let g:tsuquyomi_disable_quickfix = 1
let g:syntastic_typescript_checkers = ['tsuquyomi']
