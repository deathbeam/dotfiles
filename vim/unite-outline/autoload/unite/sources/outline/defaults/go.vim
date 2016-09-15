"=============================================================================
" File    : autoload/unite/sources/outline/defaults/go.vim
" Author  : rhysd <lin90162@yahoo.co.jp>
" Updated : 2014-05-31
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Go

function! unite#sources#outline#defaults#go#outline_info() abort
    return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

let s:outline_info = {
            \ 'heading-1': s:Util.shared_pattern('c', 'heading-1'),
            \ 'heading' : '^\s*\%(func\s\+.*{\|type\s\+\h\w*\s\+\%(struct\|interface\)\=\)',
            \ 'skip' : {
            \   'header' : s:Util.shared_pattern('c', 'header'),
            \ },
            \ 'highlight_rules' : [
            \   {
            \       'name' : 'comment',
            \       'pattern' : '/\/\/.*/',
            \   },
            \   {
            \       'name' : 'function',
            \       'pattern' : '/\%(([^)]*)\s\+\)\=\zs\h\w*\ze\s*([^)]*) : function/',
            \   },
            \   {
            \       'name' : 'interface',
            \       'pattern' : '/\h\w*\ze : interface/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'struct',
            \       'pattern' : '/\h\w*\ze : struct/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'type',
            \       'pattern' : '/\h\w*\ze : type/',
            \   },
            \ ],
            \ }

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
    let type = 'generic'
    let level = 0

    if a:which ==# 'heading-1' && a:heading_line =~# '^\s*//'
        let m_lnum = a:context.matched_lnum
        let type = 'comment'
        let level = s:Util.get_comment_heading_level(a:context, m_lnum)
        let word = a:heading_line
    elseif a:which ==# 'heading' && a:heading_line =~# '^\s*type'
        let matches = matchlist(a:heading_line, '^\s*\zstype\s\+\(\h\w*\)\s\+\([[:alpha:][\]_][[:alnum:][\]_]*\)')
        if matches[2] =~# '\%(interface\|struct\)'
            let type = matches[2]
            let word = matches[1] . ' : ' . matches[2]
        else
            let type = 'type'
            let word = matches[1] . ' : type'
        endif
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '^\s*func'
        let type = 'function'
        let word = matchstr(a:heading_line, '^\s*func\s\+\zs\%(([^)]*)\s\+\)\=\h\w*\s*([^)]*)') . ' : function'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    endif

    if level > 0
        let heading = {
                    \ 'word' : word,
                    \ 'level': level,
                    \ 'type' : type,
                    \ }
    else
        let heading = {}
    endif

    return heading
endfunction
