"=============================================================================
" File    : autoload/unite/sources/outline/defaults/magma.vim
" Author  : Sebastian Jambor <seb.jambor@gmail.com>
" Updated : 2015-05-27
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Magma files
" Version: 0.1.0

function! unite#sources#outline#defaults#magma#outline_info() abort
  return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

"-----------------------------------------------------------------------------
" Outline Info

" From the Magma handbook (http://magma.maths.usyd.edu.au/magma/handbook/):
" Identifiers (names for user variables, functions etc.) must begin with a
" letter, and this letter may be followed by any combination of letters or
" digits, provided that the name is not a reserved word (see the chapter on
" reserved words a complete list). In this definition the underscore _ is
" treated as a letter.
let s:identifierRegex = '\h[0-9a-zA-Z_]*'

let s:outline_info = {
    \ 'heading': '\%(\<function\>\|\<procedure\>\|\<intrinsic\>\)',
    \ 'highlight_rules': [
    \   {
    \     'name' : 'type',
    \     'pattern' : '/\<function\>\|\<procedure\>\|\<intrinsic\>/'
    \   },
    \   {
    \     'name' : 'function',
    \     'pattern' : '/ ' . s:identifierRegex . '\ze (/'
    \   },
    \   {
    \     'name' : 'parameter_list',
    \     'pattern' : '/(.*)/',
    \   },
    \ ],
    \}

function! s:strip(input_string) abort
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! s:outline_info.create_heading(
    \which, heading_line, matched_line, context)
  let heading = {
      \ 'word' : a:heading_line,
      \ 'level' : 1,
      \ 'type' : 'function',
      \}

  if a:heading_line =~ '^\s*\%\(\<function\>\|\<procedure\>\|\<intrinsic\>\)'
    " function <name> (<parameter_list>)
    " or
    " procedure <name> (<parameter_list>)
    " or
    " intrinsic <name> (<parameter_list>)
    let type = matchstr(a:heading_line,
        \'\%\(\<function\>\|\<procedure\>\|\<intrinsic\>\)')
    let func_name = matchstr(a:heading_line,
        \'^\s*' . type . '\s*\zs' . s:identifierRegex . '\ze\s*(')
  elseif a:heading_line =~ ':=\s*\%\(\<function\>\|\<procedure\>\)'
    " <name> := function(<parameter_list>)
    " or
    " <name> := procedure(<parameter_list>)
    let type = matchstr(a:heading_line, '\%\(\<function\>\|\<procedure\>\)')
    let func_name = matchstr(a:heading_line,
        \'^\s*\zs' . s:identifierRegex . '\ze\s*:=')
  else
    return {}
  endif

  " handle parameter lists which are spread over multiple lines;
  " ignore parameter lists which are spread over more than 20 lines
  let paramstarts = a:context.heading_lnum
  let paramends = a:context.heading_lnum
  while !(a:context.lines[paramends] =~ ')') && paramends - paramstarts < 20
      \&& paramends < len(a:context.lines) - 1
    let paramends += 1
  endwhile
  let paramline = join(
      \map(a:context.lines[paramstarts : paramends], 's:strip(v:val)'))

  let arg_list = matchstr(paramline, '(\zs.*\ze)')

  let heading.word = type . ' ' . func_name . ' (' . arg_list . ')'

  return heading
endfunction
