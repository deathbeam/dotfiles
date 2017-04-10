function! fzf#contrib#completefunc(findstart, base) abort
  let Func = function(get(g:, 'fzf#contrib#completefunc', &omnifunc))
  let results = Func(a:findstart, a:base)
  echom a:base

  if a:findstart
    return results
  endif

  let words = type(results) == type({}) && has_key(results, 'words')
        \ ? map(results.words, 'v:val.word . "\t" . v:val.menu')
        \ : results

  let results = fzf#run({
        \ 'source': words,
        \ 'down': '~40%',
        \ 'options': printf('--query "%s" +s -m', a:base)
        \ })

  if exists('*UltiSnips#ExpandSnippet')
        \ && len(results) == 1
        \ && len(results[0]) > 1
        \ && split(results[0], "\t")[1] =~? '\[snip\]'
    call feedkeys("\<c-r>=UltiSnips#ExpandSnippet()\<cr>")
  endif

  return map(results, 'split(v:val, "\t")[0]')
endfunction

function! fzf#contrib#complete(...) abort
  if len(a:000) && a:000[0]
    if getline('.')[col('.') - 1] !~# '\S'
      call feedkeys("\<tab>", 'n')
      return
    endif
  endif

  setlocal completefunc=fzf#contrib#completefunc
  setlocal completeopt=menu
  call feedkeys("\<c-x>\<c-u>", 'n')
endfunction

function! fzf#contrib#grep(query, ...) abort
  if executable('rg')
    let query = empty(a:query) ? '^.' : a:query
    let args = copy(a:000)
    let opts = len(args) > 1 ? remove(args, 0) : ''
    let command = opts . ' ' . "'".substitute(query, "'", "'\\\\''", 'g')."'"
    return call('fzf#vim#grep', extend(['rg --no-heading --column --color always '.command, 1], args))
  endif

  return call('fzf#vim#ag', insert(copy(a:000), a:query, 0))
endfunction
