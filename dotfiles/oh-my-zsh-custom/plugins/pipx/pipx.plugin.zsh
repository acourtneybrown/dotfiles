# shellcheck disable=SC2148

# Install command line completions for pipx & ensure it's bin/ is added to the path

# shellcheck disable=SC2154
if [[ ${commands[pipx]} ]]; then
  if [[ -d "${HOME}/.local/bin" ]]; then
    # Actually *want* path to be split
    # shellcheck disable=2206
    path=("${HOME}/.local/bin" ${path})
  fi
  typeset -U path
  export PATH

  _evalcache register-python-argcomplete pipx
fi
