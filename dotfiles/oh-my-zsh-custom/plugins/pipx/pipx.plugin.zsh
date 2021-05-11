# Install command line completions for pipx & ensure it's bin/ is added to the path

if [[ $commands[pipx] ]]; then
  if [[ -d "${HOME}/.local/bin" ]]; then
    path+=("${HOME}/.local/bin")
  fi
  typeset -U path
  export PATH

  eval "$(register-python-argcomplete pipx)"
fi
