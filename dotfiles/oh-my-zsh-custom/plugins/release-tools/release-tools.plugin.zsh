# shellcheck disable=SC2148

# Install command line completions for release-tools at Confluent

# shellcheck disable=SC2154
if [[ ${commands[pint]} ]]; then
  _PINT_COMPLETE=zsh_source _evalcache pint
  _PINTO_COMPLETE=zsh_source _evalcache pinto
  _TBR_COMPLETE=zsh_source _evalcache tbr
fi
