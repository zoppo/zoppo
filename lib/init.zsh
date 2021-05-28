functions:autoload regexp-replace
zmodload zsh/pcre

# Functions {{{
alias functions:add-relative='functions:add-relative "${${(%):-%x}:a:h}"'

alias functions:autoload-file-relative='functions:autoload-file-relative "${${(%):-%x}:a:h}"'
# }}}

# Plugins {{{
alias zplugload='plugins:load'
# }}}

alias source-relative='source-relative "${${(%):-%x}:a:h}"'

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
