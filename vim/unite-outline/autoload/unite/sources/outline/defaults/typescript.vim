"=============================================================================
" File    : autoload/unite/sources/outline/defaults/typescript.vim
" Author  : prabirshrestha <mail@prabir.me>
" Updated : 2015-02-15
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Typescript
" Version: 0.0.1

" Download typescript ctags at https://github.com/jb55/typescript-ctags

function! unite#sources#outline#defaults#typescript#outline_info() abort
  return s:outline_info
endfunction

let s:Ctags = unite#sources#outline#import('Ctags')
let s:Util  = unite#sources#outline#import('Util')

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
      \ 'heading_groups': {
      \   'type'   : ['modules', 'classes', 'enums', 'interfaces'],
      \   'method' : ['functions', 'varlambdas'],
      \ },
      \
      \ 'highlight_rules': [
      \   { 'name'   : 'type',
      \     'pattern': '/\S\+\ze : \%(module\|interface\|class\|enum\)/' },
      \   { 'name'   : 'method',
      \     'pattern': '/\h\w*\ze\s*(/' },
      \ ],
      \}

function! s:outline_info.extract_headings(context) abort
  return s:Ctags.extract_headings(a:context)
endfunction
