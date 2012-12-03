functions:autoload regexp-replace
zmodload zsh/pcre

# Functions {{{
# XXX: do NOT use in anonymous functions
alias functions:add-relative='functions:add-relative "${0:h:a}"'

# XXX: do NOT use in anonymous functions
alias functions:autoload-file-relative='functions:autoload-file-relative "${0:h:a}"'
# }}}

# Plugins {{{
alias zplugload='plugins:load'
# }}}

# XXX: do NOT use in anonymous functions
alias source-relative='source-relative "${0:h:a}"'

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
