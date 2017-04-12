function! fzf#contrib#completefunc(findstart, base) abort
  let Func = function(get(g:, 'fzf#contrib#completefunc', &omnifunc))
  let results = Func(a:findstart, a:base)

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
    call feedkeys("\<c-r>=UltiSnips#ExpandSnippet()\<cr>", 'n')
  endif

  return map(results, 'split(v:val, "\t")[0]')
endfunction

function! fzf#contrib#complete(...) abort
  if len(a:000) && a:000[0] && getline('.')[col('.') - 1] !~# '\S'
    call feedkeys("\<tab>", 'n')
    return
  endif

  setlocal completefunc=fzf#contrib#completefunc
  setlocal completeopt=menu
  call feedkeys("\<c-x>\<c-u>", 'n')
endfunction

function! fzf#contrib#locate(query) abort
  if executable('locate')
    let query = empty(a:query) ? '$PWD' : a:query

    return fzf#run(fzf#wrap(
          \ {'source': 'locate ' . query, 'options': '-m'}, 0))
  endif

  return fzf#contrib#grep(a:query)
endfunction

function! fzf#contrib#grep(query) abort
  if executable('rg')
    let query = empty(a:query) ? '^.' : a:query

    return fzf#vim#grep(
          \ 'rg --column --line-number --no-heading' .
          \ ' --fixed-strings --ignore-case --hidden' .
          \ ' --follow --glob "!.git/*" --color "always" ' .
          \ shellescape(query), 1, 0)
  endif

  return call('fzf#vim#ag', insert(copy(a:000), a:query, 0))
endfunction
