if terminal:is-dumb; then
  zstyle ':zoppo:*:*' color 'no'
  zstyle ':zoppo' prompt 'off'
else
  [ $LS_COLORS ]   || zstyle -s ':zoppo:colors' ls LS_COLORS
  [ $GREP_COLORS ] || zstyle -s ':zoppo:colors' grep GREP_COLORS
fi

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
