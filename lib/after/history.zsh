zdefault -s ':zoppo:history' file      HISTFILE "${ZDOTDIR:-$HOME}/.zhistory"
zdefault -s ':zoppo:history' max       HISTSIZE 10000
zdefault -s ':zoppo:history' max-saved SAVEHIST 10000

zdefault -a ':zoppo:history' options history_options \
  'bang-hist' 'extended-history' 'inc-append-history' 'share-history' 'expire-dups-first' \
  'ignore-dups' 'ignore-all-dups' 'find-no-dups' 'ignore-space' 'save-no-dups' 'verify' 'no-beep'

for option in ${history_options[*]}; do
  if [[ "$option" =~ "^no-" ]]; then
    if [ -n "$(unsetopt "${${${option#no-}//-/_}:u}" 2>&1)" ] && [ -n "$(unsetopt "HIST_${${${option#no-}//-/_}:u}" 2>&1)" ]; then
      print "history: ${option#no-} not found: could not disable"
    fi
  else
    if [ -n "$(setopt "${${option//-/_}:u}" 2>&1)" ] && [ -n "$(setopt "HIST_${${option//-/_}:u}" 2>&1)" ]; then
      print "history: $option not found: could not enable"
    fi
  fi
done
unset history_options

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
