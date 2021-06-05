# shellcheck disable=SC2148

# Install command line completions for release-tools at Confluent

# shellcheck disable=SC2154
if [[ ${commands[pint]} ]]; then
  eval "$(_PINT_COMPLETE=source pint)"
  eval "$(_PINTO_COMPLETE=source pinto)"
  eval "$(_TBR_COMPLETE=source tbr)"
fi
