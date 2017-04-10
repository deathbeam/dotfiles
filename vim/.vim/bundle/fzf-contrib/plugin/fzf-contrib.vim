inoremap <silent> <c-x><c-j> <c-o>:call fzf#contrib#complete()<cr>
inoremap <silent> <tab> <c-o>:call fzf#contrib#complete(1)<cr>
command! -bang -nargs=* Grep call fzf#contrib#grep(<q-args>, <bang>0)
