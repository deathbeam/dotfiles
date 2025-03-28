if exists("b:current_syntax") | finish | endif

" Section headers
syntax match httpStatSection "^===\s\+.\+\s\+===$" contains=httpStatSectionDelim
hi def link httpStatSection Title
syntax match httpStatSectionDelim "===" contained
hi def link httpStatSectionDelim Delimiter

" Headers
syntax match httpStatField "^\s*\zs[^:]\{-}\ze:" contains=httpStatHeaderField
hi def link httpStatField Identifier
syntax match httpStatValue ": \zs.*$"
hi def link httpStatValue String

" Method and URL
syntax match httpStatMethod "^\(GET\|POST\|PUT\|DELETE\|PATCH\|HEAD\|OPTIONS\|GRAPHQL\)" nextgroup=httpStatURL skipwhite
hi def link httpStatMethod Statement
syntax match httpStatURL "\(http\|https\)://[^ ]\+" contained
hi def link httpStatURL Underlined

" HTTP Status
syntax match httpStatStatus "HTTP/\d\.\d \d\{3}.*$" contains=httpStatStatusCode
hi def link httpStatStatus Special
syntax match httpStatStatusCode "\d\{3}" contained
hi def link httpStatStatusCode Number

" Highlight JSON response keys
syntax match JSONKey /"[^"]\+"\s*:/ containedin=ALL
hi def link JSONKey Type

" Highlight JSON response values
syntax match JSONValue /: \("[^"]*"\|[0-9]\+\|true\|false\|null\)/ containedin=ALL
hi def link JSONValue String

" Highlight XML tags
syntax match XMLTag /<\/?[a-zA-Z0-9_-]\+\( [^>]*\)?>/ containedin=ALL
hi def link XMLTag Keyword

" Highlight XML attributes
syntax match XMLAttribute /[a-zA-Z0-9_-]\+="[^"]*"/ containedin=ALL
hi def link XMLAttribute Identifier

" Request separator
syntax match StatSeparator "^-\{3,}$"
hi def link StatSeparator Delimiter

let b:current_syntax = "http_stat"
