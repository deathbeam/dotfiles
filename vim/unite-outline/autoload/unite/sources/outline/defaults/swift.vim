"=============================================================================
" File    : autoload/unite/sources/outline/defaults/go.vim
" Author  : rhysd <lin90162@yahoo.co.jp>
" Updated : 2014-06-07
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Apple Swift

function! unite#sources#outline#defaults#swift#outline_info() abort
    return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

let s:outline_info = {
            \ 'heading-1': s:Util.shared_pattern('c', 'heading-1'),
            \ 'heading' : '\%(\<\%(typealias\|func\|enum\|case\|struct\|class\|protocol\|subscript\|init\|deinit\|extension\|operator\)\>\|^}\)',
            \ 'skip' : {
            \   'header' : s:Util.shared_pattern('c', 'header'),
            \ },
            \ 'highlight_rules' : [
            \   {
            \       'name' : 'comment',
            \       'pattern' : '/\/\/.*/',
            \   },
            \   {
            \       'name' : 'typealias',
            \       'pattern' : '/\h\w*\ze : type\>/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'function',
            \       'pattern' : '/.*\ze : func\>/',
            \   },
            \   {
            \       'name' : 'enum',
            \       'pattern' : '/\h\w* : enum\>/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'case',
            \       'pattern' : '/\<case\s\+\zs.*/',
            \       'highlight' : unite#sources#outline#get_highlight('macro'),
            \   },
            \   {
            \       'name' : 'struct',
            \       'pattern' : '/\h\w*\ze : struct\>/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'class',
            \       'pattern' : '/\S*\ze : class\>/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'protocol',
            \       'pattern' : '/\h\w*\ze : protocol\>/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'subscript',
            \       'pattern' : '/\<subscript\>/',
            \       'highlight' : unite#sources#outline#get_highlight('function'),
            \   },
            \   {
            \       'name' : 'init',
            \       'pattern' : '/\<init\>/',
            \       'highlight' : unite#sources#outline#get_highlight('function'),
            \   },
            \   {
            \       'name' : 'deinit',
            \       'pattern' : '/\<deinit\>/',
            \       'highlight' : unite#sources#outline#get_highlight('function'),
            \   },
            \   {
            \       'name' : 'extension',
            \       'pattern' : '/[^:]\+\ze : extension/',
            \       'highlight' : unite#sources#outline#get_highlight('type'),
            \   },
            \   {
            \       'name' : 'operator',
            \       'pattern' : '/\S\+\ze : operator/',
            \       'highlight' : unite#sources#outline#get_highlight('function'),
            \   },
            \ ],
            \ }

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
    let type = 'generic'
    let level = 0

    if a:which ==# 'heading-1' && a:heading_line =~# '^\s*//'
        let m_lnum = a:context.matched_lnum
        let type = 'comment'
        let word = a:heading_line
        let level = s:Util.get_comment_heading_level(a:context, m_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<typealias\>'
        let type = 'typealias'
        let word = substitute(matchstr(a:heading_line, '\<typealias\s\+\zs\h\w*'), '\s\+', ' ', 'g') . ' : type'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<func\>'
        let type = 'function'
        let word = substitute(matchstr(a:heading_line, '\<func\s\+\zs\%(\S\&[^<(]\)*'), '\s\+', ' ', 'g') . ' : func'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<enum\>'
        let type = 'enum'
        let word = substitute(matchstr(a:heading_line, '\<enum\s\+\zs\h\w*'), '\s\+', ' ', 'g') . ' : enum'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<case\>'
        let type = 'case'
        let word = substitute(matchstr(a:heading_line, '\<case\s\+[^:]\+'), '\s\+', ' ', 'g')
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<class\>'
        let type = 'class'
        let word = substitute(matchstr(a:heading_line, '\<class\s\+\zs\h\w*'), '\s\+', ' ', 'g') . ' : class'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<struct\>'
        let type = 'struct'
        let word = substitute(matchstr(a:heading_line, '\<struct\s\+\zs\h\w*'), '\s\+', ' ', 'g') . ' : struct'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<protocol\>'
        let type = 'protocol'
        let word = substitute(matchstr(a:heading_line, '\<protocol\s\+\zs\h\w*'), '\s\+', ' ', 'g') . ' : protocol'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<init\s*('
        let type = 'init'
        let word = 'init'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<deinit\s*('
        let type = 'deinit'
        let word = 'deinit'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<extension\>'
        let type = 'extension'
        let word = substitute(matchstr(a:heading_line, '\<extension\s\+\zs[^:]\+'), '\s\+', ' ', 'g') . ' : extension'
        let level = s:Util.get_indent_level(a:context, a:context.heading_lnum)
    elseif a:which ==# 'heading' && a:heading_line =~# '\<operator\>'
        let type = 'operator'
        let word = substitute(matchstr(a:heading_line, '\<operator\s\+\zs\%(\h\w*\s\+\)\=\S\+'), '\s\+', ' ', 'g') . ' : operator'
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

