imap <c-x><c-j> <c-o>:call fzf#contrib#trigger_complete()<cr>
inoremap <silent> <tab> <c-o>:call fzf#contrib#tab_complete()<cr>
command! -bang -nargs=* Grep call fzf#contrib#grep(<q-args>, <bang>0)
