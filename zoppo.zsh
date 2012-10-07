# load libraries
typeset -ga fpath
fpath=("${0:h:a}/lib/functions" $fpath)

LIBPATH="${0:h:a}/lib"
function {
  local zfunction

  setopt LOCAL_OPTIONS EXTENDED_GLOB
  for zfunction ("$LIBPATH"/functions/^([._]|README)*(.N:t))
    autoload -Uz -- "$zfunction"
}
unset LIBPATH

source "${0:h:a}/lib/init.zsh"

# set default paths
zdefault ':zoppo:internal:path' base "${0:h:a}"
zdefault ':zoppo:internal:path' plugins "${0:h:a}/plugins"
zdefault ':zoppo:internal:path' prompts "${0:h:a}/prompts"

if [[ -s "${ZDOTDIR:-$HOME}/.zopporc" ]]; then
  source "${ZDOTDIR:-$HOME}/.zopporc"
fi

if terminal:is-dumb; then
  zstyle ':zoppo:*:*' color 'no'
  zstyle ':zoppo' prompt 'off'
fi

functions:add "$(path:prompts)"
functions:autoload promptinit && promptinit
typeset -a zoppo_prompt
zdefault -a ':zoppo' prompt zoppo_prompt 'off'
prompt "$zoppo_prompt[@]"
unset zoppo_prompt

zstyle -a ':zoppo:load' modules zmodules
for zmodule ("$zmodules[@]") zmodload "zsh/${(z)module}"
unset zmodule{,s}

zstyle -a ':zoppo:load' functions zfunctions
functions:autoload "$zfunctions[@]" 2>/dev/null
unset zfunctions

zstyle -a ':zoppo:load' plugins zplugins
zplugload "$zplugins[@]" 2>/dev/null
unset zplugins

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
