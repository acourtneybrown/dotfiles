# shellcheck disable=SC2148

NVM_DIR="${HOME}/.nvm"

if command -v nvm >/dev/null && [[ -d ${NVM_DIR} ]]; then
  function nvm_prompt_info() {
    # shellcheck disable=SC2155
    local version="$(nvm current)"
    echo "${version:gs/%/%%}"
  }

  # shellcheck disable=SC2016
  RPROMPT+=' n$(nvm_prompt_info)'

  export NVM_DIR
else
  unset NVM_DIR
fi
