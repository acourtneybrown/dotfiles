# shellcheck disable=SC2148

# Install command line completions for pipx & ensure it's bin/ is added to the path

# shellcheck disable=SC2154
if [[ ${commands[pipx]} ]]; then
  if [[ -d "${HOME}/.local/bin" ]]; then
    path+=("${HOME}/.local/bin")
  fi
  typeset -U path
  export PATH

  _evalcache register-python-argcomplete pipx
fi
