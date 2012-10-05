# Helpers {{{

# XXX: do NOT use in anonymous functions
function source-relative {
  (( $+2 )) || {
    print 'source-relative: not enough arguments' >&2
    return 1
  }

  source "$1/$2"
}
alias source-relative='source-relative "${0:h:a}"'

function is-callable {
  (( $+1 )) || {
    print 'is-callable: not enough arguments' >&2
    return 1
  }

  (( $+builtins[$1] )) || (( $+functions[$1] )) || (( $+aliases[$1] )) || (( $+commands[$1] ))
}

function zdefault {
  case "$1" in
    -[abs])
      (( $+4 )) || {
        print 'zdefault: not enough arguments' >&2
        return 1
      }

      zstyle -T "$2" "$3" && zstyle "$2" "$3" "${(@)argv[5,-1]}"
      zstyle "${(@)argv[1,4]}"
      ;;

    -*) print "zdefault: invalid option: $1"
      return 1
      ;;

    *)
      (( $+2 )) || {
        print 'zdefault: not enough arguments' >&2
        return 1
      }

      zstyle -T "$1" "$2" && zstyle "$@"
  esac
}

# Path Helpers {{{
zdefault ':zoppo:internal:path' base "${0:h:a}"
zdefault ':zoppo:internal:path' lib "${0:h:a}/lib"
zdefault ':zoppo:internal:path' plugins "${0:h:a}/plugins"
zdefault ':zoppo:internal:path' prompts "${0:h:a}/prompts"

function path:base {
  local path
  zstyle -s ':zoppo:internal:path' base path
  print -- "$path"
}

function path:lib {
  local path
  zstyle -s ':zoppo:internal:path' lib path
  print -- "$path"
}

function path:plugins {
  local path
  zstyle -s ':zoppo:internal:path' plugins path
  print -- "$path"
}

function path:prompts {
  local path
  zstyle -s ':zoppo:internal:path' prompts path
  print -- "$path"
}
# }}}

# Functions Helpers {{{
function functions:add {
  (( $+1 )) || {
    print 'functions:add: not enough arguments' >&2
    return 1
  }

  typeset -ga fpath
  fpath=($@ $fpath)
}

# XXX: do NOT use in anonymous functions
function functions:add-relative {
  (( $+2 )) || {
    print 'functions:add-relative: not enough arguments' >&2
    return 1
  }

  functions:add "$1/${^${(@)argv[2,-1]}}"
}
alias functions:add-relative='functions:add-relative "${0:h:a}"'

function functions:autoload {
  (( $+1 )) || {
    print "functions:autoload: not enough arguments" >&2
    return 1
  }

  local fun
  for fun ("$@")
    autoload -Uz "$fun"
}

function functions:autoload-file {
  (( $+2 )) || {
    print "functions:autoload-file: not enough arguments" >&2
    return 1
  }

  for name ("${(@)argv[2,-1]}")
    eval "function $name {
      unfunction $name
      source ${(q)1}
      $name \"\$@\"
    }"
}

# XXX: do NOT use in anonymous functions
function functions:autoload-file-relative {
  (( $+3 )) || {
    print "functions:autoload-file-relative: not enough arguments" >&2
    return 1
  }

  functions:autoload-file "$1/$2" "${(@)argv[3,-1]}"
}
alias functions:autoload-file-relative='functions:autoload-file-relative "${0:h:a}"'
#}}}

# Plugin Helpers {{{
function plugin:load {
  (( $+1 )) || {
    print "plugin:load: not enough arguments" >&2
    return 1
  }

  local -a zplugins
  local zplugin
  local PLUGSPATH="$(path:plugins)"

  zplugins=("$argv[@]")

  for zplugin ("$zplugins[@]"); do
    if zstyle -t ":zoppo:internal:plugin:$zplugin" loaded 'yes'; then
      continue
    elif [[ ! -d "$PLUGSPATH/$zplugin" ]]; then
      print "$0: no such plugin: $zplugin" >&2
      continue
    else
      local PLUGPATH="$PLUGSPATH/$zplugin"

      functions:add "$PLUGPATH"/functions(/FN) 2>/dev/null

      function {
        local zfunction

        setopt LOCAL_OPTIONS EXTENDED_GLOB

        for zfunction ("$PLUGPATH"/functions/^([_.]*|README*|after)(.N:t))
          functions:autoload "$zfunction"
      }

      zstyle ":zoppo:internal:plugin:$zplugin" path "$PLUGPATH"

      if [[ -s "$PLUGPATH/init.zsh" ]]; then
        source "$PLUGPATH/init.zsh"
      fi

      if (( $? == 0 )); then
        zstyle ":zoppo:internal:plugin:$zplugin" loaded 'yes'
      else
        fpath[(r)"$PLUGPATH"/functions]=()

        function {
          local zfunction

          setopt LOCAL_OPTIONS EXTENDED_GLOB

          for zfunction ("$PLUGPATH"/functions/^([_.]*|README*)(.N:t))
            unfunction "$zfunction"
        }
      fi
    fi
  done
}

function plugin:is-loaded {
  (( $+1 )) || {
    print 'plugin:is-loaded: not enough arguments' >&2
    return 1
  }

  zstyle -t ":zoppo:internal:plugin:$1" loaded 'yes'
}

alias zplugload='plugin:load'
# }}}

# Library Helpers {{{
function lib:load {
  if [[ -f "$1" ]]; then
    source "$1"
  elif [[ -d "$1" ]]; then
    functions:add "$1"/functions(/FN) 2>/dev/null

    local LIBPATH="$1"
    function {
      local zfunction

      setopt LOCAL_OPTIONS EXTENDED_GLOB

      for zfunction ("$LIBPATH"/functions/^([_.]*|README*)(.N:t))
        functions:autoload "$zfunction"
    }

    if [[ -s "$1/init.sh" ]]; then
      source "$1/init.sh"
    fi

    if (( $? != 0 )); then
      fpath[(r)"$1"/functions]=()

      function {
        local zfunction

        setopt LOCAL_OPTIONS EXTENDED_GLOB

        for zfunction ("$LIBPATH"/functions/^([_.]*|README*)(.N:t))
          unfunction "$zfunction"
      }
    fi
  fi
}

function lib:load-all {
  local zlib

  for zlib ("$1"/^([_.]*|README*)(N))
    lib:load "$zlib"
}
# }}}

# }}}

lib:load-all "$(path:lib)"

if [[ -s "${ZDOTDIR:-$HOME}/.zopporc" ]]; then
  source "${ZDOTDIR:-$HOME}/.zopporc"
fi

if terminal:is-dumb; then
  zstyle ':zoppo:*:*' color 'no'
  zstyle ':zoppo' prompt 'off'
fi

functions:add "$(path:prompts)"
autoload -Uz promptinit && promptinit
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
