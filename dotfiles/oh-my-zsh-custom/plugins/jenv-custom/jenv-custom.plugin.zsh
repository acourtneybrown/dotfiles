# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[jenv]} ]]; then
  # shellcheck disable=SC2016
  RPROMPT+=' j$(jenv_prompt_info)'
fi
