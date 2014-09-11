# Minimum Version Check {{{
if ! autoload -Uz is-at-least || ! is-at-least '4.3.10'; then
  print 'zoppo: old shell detected, minimum required: 4.3.10' >&2
  return 1
fi
# }}}

# Load Libraries {{{
typeset -ga fpath
fpath=("${0:h:a}/lib/functions" $fpath)

LIBPATH="${0:h:a}/lib"
function {
  local zfunction

  setopt LOCAL_OPTIONS EXTENDED_GLOB BARE_GLOB_QUAL
  for zfunction ("$LIBPATH"/functions/^([._]|README)*(.N:t))
    autoload -Uz -- "$zfunction"
}
unset LIBPATH

source "${0:h:a}/lib/init.zsh"
# }}}

# Load Arguments {{{
while (( $+1 )); do
  case "$1" in
    -profile)
      shift

      if [[ -n "$1" && "$1" != -* ]]; then
        export ZOPPO_PROFILE="$1"
      else
        export ZOPPO_PROFILE=1
      fi

      ;;

    -config)
      shift

      zstyle ':zoppo' config "$1"
      shift

      ;;

    *) shift ;;
  esac
done
# }}}

# Profile {{{
if profile:is-enabled; then
  zmodload zsh/zprof
fi
# }}}

# Default Paths {{{
zdefault ':zoppo:path' base "${0:h:a}"
zdefault ':zoppo:path' cache "${ZDOTDIR:-$HOME}/.zcache"
zdefault ':zoppo:path' plugins "${0:h:a}/plugins"
zdefault ':zoppo:path' prompts "${0:h:a}/prompts"
# }}}

# Load Zoppo Configuration {{{
zdefault -s ':zoppo' config zconfig "${ZDOTDIR:-$HOME}/.zopporc"
if [[ -s "$zconfig" ]]; then
  source "$zconfig"
fi
unset zconfig
# }}}

# Cache Directory {{{
if [[ ! -d $(path:cache) ]]; then
  mkdir -p "$(path:cache)"
fi
# }}}

# Auto Updating {{{
if zdefault -t ':zoppo:update' auto 'no'; then
  if zdefault -t ':zoppo:update' force 'no' && zoppo:needs-update 1; then
    zoppo:update -f && zoppo:restart
  elif zoppo:needs-update 8; then
    zoppo:update && zoppo:restart
  fi
fi
# }}}

# Handle Dumb Terminal {{{
if terminal:is-dumb; then
  zstyle ':zoppo:*:*' color 'no'
  zstyle ':zoppo' prompt 'off'
fi
# }}}

# Environment Options {{{
function {
  local -a zoptions
  local option

  zdefault -a ':zoppo' options zoptions \
    'brace-ccl' 'rc-quotes' 'no-mail-warning' 'long-list-jobs' 'auto-resume' 'notify' \
    'no-bg-nice' 'no-hup' 'no-check-jobs'

  for option ("$zoptions[@]"); do
    if [[ "$option" =~ "^no-" ]]; then
      if ! options:disable "${option#no-}"; then
        print "zoppo: ${option#no-} not found: could not disable"
      fi
    else
      if ! options:enable "$option"; then
        print "zoppo: $option not found: could not enable"
      fi
    fi
  done
}
# }}}

# Load Modules {{{
zstyle -a ':zoppo:load' modules zmodules
for zmodule ("$zmodules[@]") zmodload "zsh/${(z)module}"
unset zmodule{,s}
# }}}

# Autoload Functions {{{
zstyle -a ':zoppo:load' functions zfunctions
(( $#zfunctions > 0 )) && functions:autoload "$zfunctions[@]"
unset zfunctions
# }}}

# Load Plugins {{{
zstyle -a ':zoppo:load' plugins zplugins
(( $#zplugins > 0 )) && zplugload "$zplugins[@]"
unset zplugins
# }}}

if zoppo:has-been-updated; then
  hooks:call zoppo_updated
fi

hooks:call zoppo_postinit

# Profile {{{
if profile:is-enabled; then
  zprof >! $(profile:path)
fi
# }}}

# Initialize Prompts {{{
typeset -a prompts_path
zstyle -a ':zoppo:path' prompts prompts_path
(( $#prompts_path > 0 )) && functions:add "${prompts_path[@]}"
unset prompts_path
functions:autoload promptinit && promptinit
typeset -a zoppo_prompt
zdefault -a ':zoppo' prompt zoppo_prompt 'off'
prompt "$zoppo_prompt[@]"
unset zoppo_prompt
# }}}

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
