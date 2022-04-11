# shellcheck disable=SC2148

# Install command line completions for release-tools at Confluent

# shellcheck disable=SC2154
if [[ ${commands[pint]} ]]; then
  _evalcache _PINT_COMPLETE=source pint
  _evalcache _PINTO_COMPLETE=source pinto
  _evalcache _TBR_COMPLETE=source tbr
fi
