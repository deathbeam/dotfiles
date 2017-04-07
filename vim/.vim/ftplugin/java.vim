setlocal omnifunc=javacomplete#Complete
setlocal makeprg=mvn\ $*
setlocal errorformat=\[%t%[A-Z]%#]\ %f:[%l\\,%c]\ %m,
      \\[%t%[A-Z]%#]\ %f:%l:\ %m,
      \\%A%f:[%l\\,%c]\ %m,
      \\%Csymbol%.%#:\ %m,
      \\%Zlocation%.%#:\ %m,
      \\%AEmbedded\ error:%.%#\ -\ %f:%l:\ %m,
      \\%-Z\ %p^,
      \\%A%f:%l:\ %m,
      \\%-Z\ %p^,
      \\%ARunning\ %f,
      \\%+ZTests\ run%.%#FAILURE!%.%#,
      \\%ARunning\ %f,
      \\%C%.%#,
      \\%+ZTests\ run%.%#FAILURE!%.%#,
      \\%-G%.%#

" Completor integration
let g:completor_java_omni_trigger = '(\w+|[^\. \t0-9]+\.\w*)$'

" JavaComplete adjustments
let g:JavaComplete_ImportSortType = 'packageName'
let g:JavaComplete_ImportOrder = ['*']

