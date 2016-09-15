"=============================================================================
" File    : autoload/unite/sources/outline/defaults/asciidoc.vim
" Author  : thawk
" Updated : 2015-07-25
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Asciidoc
" Version: 0.0.1

function! unite#sources#outline#defaults#asciidoc#outline_info() abort
  return s:outline_info
endfunction

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
      \ 'heading'  : '^=\{1,5}\s',
      \ 'heading+1': '^=\{4,}$\|^-\{4,}$\|^\~\{4,}$\|^\^\{4,}$\|^+\{4,}$',
      \ }

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
  let heading = {
        \ 'word' : a:heading_line,
        \ 'level': 0,
        \ 'type' : 'generic',
        \ }

  if a:which ==# 'heading'
    let heading.level = strlen(matchstr(a:heading_line, '^=\+'))
    let heading.word = substitute(heading.word, '^=\+\s*', '', '')
    let heading.word = substitute(heading.word, '\s*=\+\s*$', '', '')
  elseif a:which ==# 'heading+1' && strwidth(a:heading_line) == strwidth(a:matched_line)
    if a:matched_line =~ '^='
      let heading.level = 1
    elseif a:matched_line =~ '^-'
      let heading.level = 2
    elseif a:matched_line =~ '^\~'
      let heading.level = 3
    elseif a:matched_line =~ '^\^'
      let heading.level = 4
    else
      let heading.level = 5
    endif
  endif

  if heading.level > 0
    return heading
  else
    return {}
  endif
endfunction
