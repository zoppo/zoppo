#!/usr/bin/env zsh

emulate -L zsh

if (( $+commands[figlet] )); then
  figlet -w "${COLUMNS:-80}" 'ZOPPO INSTALLER'
else
  print ' ________  ____  ____   ___    ___ _   _ ____ _____  _    _     _     _____ ____'
  print '|__  / _ \|  _ \|  _ \ / _ \  |_ _| \ | / ___|_   _|/ \  | |   | |   | ____|  _ \'
  print '  / / | | | |_) | |_) | | | |  | ||  \| \___ \ | | / _ \ | |   | |   |  _| | |_) |'
  print ' / /| |_| |  __/|  __/| |_| |  | || |\  |___) || |/ ___ \| |___| |___| |___|  _ <'
  print '/____\___/|_|   |_|    \___/  |___|_| \_|____/ |_/_/   \_\_____|_____|_____|_| \_\'
  print
fi

function alert {
  print -n -- " \e[1;32m/\\\e[0m "
  print -n -- "$@"
}

function query {
  print -n -- " \e[1;32m?\e[0m "
  print -n -- "$@"
}

function info {
  print -n -- " \e[1;33m!\e[0m "
  print -n -- "$@"
}

function die {
  alert "$@" >&2
  print >&2
  exit 1
}

(( $+commands[git] )) || die "Install git first."

CONFIRM=true
if (( $# == 1 )) && [[ "$1" == '-y' ]]; then
  CONFIRM=false
elif (( $# > 0 )); then
  die "USAGE: $0 [-y]"
fi

if [[ -e "${ZDOTDIR:-$HOME}/.zoppo" ]]; then
  if [[ "$CONFIRM" == false ]]; then
    rm -rf "${ZDOTDIR:-$HOME}/.zoppo"
  else
    query "Do you want to remove ${ZDOTDIR:-$HOME}/.zoppo? (y/N) "
    if read -q; then
      print
      rm -rf "${ZDOTDIR:-$HOME}/.zoppo"
    else
      alert "\nzoppo not installed\n"
      exit 0
    fi
  fi
fi

git clone --branch default --recursive git://github.com/zoppo/zoppo.git "${ZDOTDIR:-$HOME}/.zoppo" || die "Can't clone repo in ${ZDOTDIT:-$HOME}/.zoppo"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zoppo/templates/^README.md(.N); do
  if [[ -e "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]]; then
    if [[ "$CONFIRM" == false ]]; then
      < "$rcfile" >>! "${DOTDIR:-$HOME}/.${rcfile:t}"
    else
      query "${ZDOTDIR:-$HOME}/.${rcfile:t} already exists, do you want to continue? ([M]erge/[o]verwrite) "
      read -k1
      print
      case "$REPLY" in
        [Oo])
          < "$rcfile" >! "${ZDOTDIR:-$HOME}/.${rcfile:t}"
          ;;
        *)
          < "$rcfile" >>! "${ZDOTDIR:-$HOME}/.${rcfile:t}"
          ;;
      esac
    fi
  else
    < "$rcfile" >! "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  fi
done

chsh -s =zsh

info "Please restart shell now (hint: exec zsh)\n"
