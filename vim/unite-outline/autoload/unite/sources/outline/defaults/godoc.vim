"=============================================================================
" File    : autoload/unite/sources/outline/defaults/go.vim
" Author  : rhysd <lin90162@yahoo.co.jp>
" Updated : 2015-04-25
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Go

function! unite#sources#outline#defaults#godoc#outline_info() abort
    return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

let s:outline_info = {
            \ 'heading' : '^\%(\u[[:upper:] ]*\|\%(package\|func\|type\|var\|const\)\s\+.\+\|)\|\s\+\h\w*\s\+=\s\+.*\)$',
            \ 'end' : '^\s*)\s*$',
            \ 'highlight_rules' : [
            \   {
            \       'name' : 'title',
            \       'pattern' : '/\<\u\+\>/',
            \       'highlight' : 'Title',
            \   },
            \   {
            \       'name' : 'function',
            \       'pattern' : '/\%(([^)]*)\s\+\)\=\zs\h\w*\ze\s*([^)]*) : function/',
            \   },
            \   {
            \       'name' : 'type',
            \       'pattern' : '/\<\h\w*\ze : \%(interface\|struct\|type\)\>/',
            \   },
            \   {
            \       'name' : 'variable',
            \       'pattern' : '/\<\h\w*\ze : \%(variable\|constant\)/',
            \       'highlight' : 'Identifier',
            \   },
            \   {
            \       'name' : 'keyword',
            \       'pattern' : '/\<\%(function\|type\|struct\|interface\|variable\|package\|constant\)\>/',
            \       'highlight' : 'Keyword',
            \   },
            \   {
            \       'name' : 'package',
            \       'pattern' : '/\<\h\w*\ze : package\>/',
            \       'highlight' : 'PreProc',
            \   },
            \ ],
            \ }

let s:parsing_block = ''

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
    if a:which !=# 'heading'
        return {}
    endif

    if a:heading_line =~# '^\u[[:upper:] ]*$'
        return {'word' : a:heading_line, 'type' : 'title', 'level' : 1}
    endif

    if s:parsing_block !=# '' && a:heading_line =~# '^\s\+\h\w* ='
        let type = s:parsing_block
        let word = matchstr(a:heading_line, '^\s\+\(\h\w*\)') . ' : ' . type
        return {'type' : type, 'word' : word, 'level' : 2}
    endif

    if a:heading_line ==# ')'
        let s:parsing_block = ''
        return {}
    endif

    if a:heading_line =~# '^type\>'
        let matches = matchlist(a:heading_line, '^type\s\+\(\h\w*\)\s\+\([[:alpha:][\]_][[:alnum:][\]_]*\)')
        if matches[2] =~# '^\%(interface\|struct\)$'
            let type = matches[2]
            let word = matches[1] . ' : ' . matches[2]
        else
            let type = 'type'
            let word = matches[1] . ' : type'
        endif
    elseif a:heading_line =~# '^func\>'
        let type = 'function'
        let word = matchstr(a:heading_line, '^func\s\+\zs\%(([^)]*)\s\+\)\=\h\w*\s*([^)]*)') . ' : function'
    elseif a:heading_line =~# '^var\>'
        if a:heading_line =~# '($'
            let s:parsing_block = 'variable'
            return {}
        endif
        let type = 'variable'
        let word = matchstr(a:heading_line, '^var\s\+\zs\h\w*') . ' : variable'
    elseif a:heading_line =~# '^const\>'
        if a:heading_line =~# '($'
            let s:parsing_block = 'constant'
            return {}
        endif
        let type = 'constant'
        let word = matchstr(a:heading_line, '^const\s\+\zs\h\w*') . ' : constant'
    elseif a:heading_line =~# '^package\>'
        let type = 'package'
        let word = matchstr(a:heading_line, '^package\s\+\zs\h\w*') . ' : package'
    else
        return {}
    endif

    return {'word' : word, 'level' : 2, 'type' : type}
endfunction
