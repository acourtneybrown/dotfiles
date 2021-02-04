# Install command line completions for release-tools at Confluent

if [[ $commands[pint] ]]; then
  eval "$(_PINT_COMPLETE=source $(which pint))"
  eval "$(_PINTO_COMPLETE=source $(which pinto))"
  eval "$(_TBR_COMPLETE=source $(which tbr))"
fi
