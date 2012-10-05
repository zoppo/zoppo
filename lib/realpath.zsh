if ! is-callable realpath; then
  function realpath {
    [ $# = 0 ] && {
      cat <<EOF
USAGE: $0 path [path ...]
EOF
      return 1
    }

    for f ("$@")
      print ${f}(:A)
  }
fi

# vim: set ft=zsh sts=2 ts=2 sw=2 et:
