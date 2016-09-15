"=============================================================================
" File    : autoload/unite/sources/outline/defaults/pony.vim
" Author  : locksfree <locksfree[at]gmail.com>
" Updated : 2016-07-17
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Pony
" Version: 0.1.0

function! unite#sources#outline#defaults#pony#outline_info() abort
  return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

"---------------------------------------
" Sub Pattern

let s:pat_type = '\%(interface\|be\|type\|class\|trait\|actor\|fun\|new\|primitive\)\>'
let s:pat_typename = '\%(iso\|trn\|ref\|tag\|val\|box\)\?\s*\zs\h\%(\w\+\)'

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
      \ 'heading'  : '^\s*\%(\h\w*\s\+\)*' . s:pat_type,
      \
      \ 'heading_groups': {
      \   'type'     : ['type', 'interface', 'class', 'trait', 'actor', 'primitive'],
      \   'function' : ['fun', 'new', 'be'],
      \ },
      \ 'not_match_patterns': [
      \   s:Util.shared_pattern('*', 'parameter_list'),
      \ ],
      \
      \ 'highlight_rules': [
      \   { 'name'   : 'type',
      \     'pattern': '/\S\+\ze : \%(interface\|class\|trait\|actor\|type\|primitive\)/' },
      \   { 'name'   : 'function',
      \     'pattern': '/\(new\|be\|fun\)/' },
      \   { 'name'   : 'parameter_list',
      \     'pattern': '/(.*)/' },
      \ ],
      \}

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
  let h_lnum = a:context.heading_lnum
  let level = s:Util.get_indent_level(a:context, h_lnum)
  let heading = {
                \ 'word' : a:heading_line,
                \ 'level': level,
                \ 'type' : 'generic',
                \ }

  if a:which ==# 'heading'
    let heading.word = substitute(heading.word, '\s*{.*$', '', '')

    let heading_type = ''
    if heading.word =~# '^\s*interface\>'
      let heading_type = 'interface'
    elseif heading.word =~# '^\s*class\>'
      let heading_type = 'class'
    elseif heading.word =~# '^\s*trait\>'
      let heading_type = 'trait'
    elseif heading.word =~# '^\s*actor\>'
      let heading_type = 'actor'
    elseif heading.word =~# '^\s*type\>'
      let heading_type = 'type'
    elseif heading.word =~# '^\s*primitive\>'
      let heading_type = 'primitive'
    endif
    if heading_type !=# ''
       let heading.type = 'type'
       let heading.level = 1
    endif

    if heading.type !=# 'generic'
      let name = matchstr(heading.word, '\zs\<' . heading_type . '\s\+' . s:pat_typename)
      if len(name) > 0
         let heading.word = name . ' : ' . heading_type
      else
         let heading.word = ''
         let heading.type = 'generic'
      end
    end

    if heading.word =~# '^\s*\%(fun\|be\|new\)\>'
      " Function / Behaviour / Constructor
      let heading.type = 'function'
      let heading.level = 2
      let fun_type = matchstr(heading.word, '\%(fun\|be\|new\)')

      " There might be a receiver capability, we need to get it if it is there
      let receiver_capa = matchstr(heading.word, '\%(fun\|be\|new\)\s\+\%(ref\|box\|trn\|iso\|val\|tag\)')
      let receiver_capa = matchstr(receiver_capa, '\%(ref\|box\|trn\|iso\|val\|tag\)', '')
      if len(receiver_capa) > 0
         let receiver_capa = '[' . receiver_capa . '] '
      endif

      " There might be a return type, we need to get it if it is there
      let return_type = matchstr(heading.word, '[\)]\s*\:\%([^>]\+\)\%([=][>]\|$\)')
      if len(return_type) > 0
         let return_type = matchstr(return_type, ':.*', '')
         let return_type = substitute(return_type, '\%(^\s\+\|\s\+$\)', '', 'g')

         " The line may end with the start/full body starting with => or
         " simply stop mid way $
         if len(matchstr(return_type, '[=][>]')) > 0
            let return_type = return_type[1:-4]
         else
            let return_type = return_type[1:-2]
         endif
         let return_type = ' : ' . substitute(return_type, '\%(^\s\+\|\s\+$\)', '', 'g')
      endif

      " Let's extract the name
      let name = matchstr(heading.word, '\zs\<' . fun_type . '\(\s\+\zs\h\w*\)\+')

      " Let's indicate the visibility (+ or -) for package or public
      let prefix = '+ '
      if len(matchstr(name, '^\s*[_]')) > 0
         let prefix = '- '
      end

      let heading.word = prefix . fun_type . ' ' . receiver_capa . name . '(...)' . return_type
    endif

    " For anything but a function, we need to put the visibility
    if heading.type !=# 'function' && heading.type !=# 'generic'
      let prefix = '+ '
      if len(matchstr(heading.word, '^\s*[_]')) > 0
        let prefix = '- '
      endif
      let heading.word = prefix . heading.word
    endif

    if len(substitute(heading.word, '\%(^\s\+\|\s\+$\)', '', 'g')) == 0 || heading.type ==# 'generic'
      let heading = {}
    endif
  endif

  return heading
endfunction

function! s:outline_info.need_blank_between(cand1, cand2, memo) abort
  if a:cand1.source__heading_type ==# 'function' && a:cand2.source__heading_type ==# 'function'
    " Don't insert a blank between two sibling functions.
    return 0
  else
    return a:cand1.source__has_marked_child || a:cand2.source__has_marked_child
  endif
endfunction
