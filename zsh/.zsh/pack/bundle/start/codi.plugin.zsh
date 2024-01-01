# Codi
# Usage: codi [filetype]
codi() {
  local cmd="CodiSelect"
  if [[ -n "$1" ]]; then
    cmd="Codi $1"
  fi
  vim -c \
    "let g:startify_disable_at_vimenter = 1 |\
    set bt=nofile ls=0 noru nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    $cmd"
}
