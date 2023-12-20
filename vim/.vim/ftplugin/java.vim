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
