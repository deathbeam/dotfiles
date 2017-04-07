setlocal omnifunc=htmlcomplete#CompleteTags

" Completor integration
let g:completor_html_omni_trigger = '</$'

" Syntastic adjustments
let g:syntastic_html_checkers = ['htmlhint']
