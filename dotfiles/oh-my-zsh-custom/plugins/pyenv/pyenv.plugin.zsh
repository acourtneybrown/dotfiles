# shellcheck disable=SC2148

export PYENV_ROOT="${HOME}/.pyenv"

if [[ -d ${PYENV_ROOT} ]]; then
  # shellcheck disable=SC2206
  path=("${PYENV_ROOT}/bin/" $path)
  typeset -U path
  export PATH
  _evalcache pyenv init - zsh

  function pyenv_prompt_info() {
    # shellcheck disable=SC2155
    local version="$(pyenv version-name)"
    echo "${version:gs/%/%%}"
  }
else
  # Fall back to system python
  function pyenv_prompt_info() {
    # shellcheck disable=SC2155
    local version="$(python3 -V 2>&1 | cut -d' ' -f2)"
    echo "system: ${version:gs/%/%%}"
  }

  unset PYENV_ROOT
fi

# Want pyenv_prompt_info evaluated later
# shellcheck disable=SC2016
RPROMPT+=' py$(pyenv_prompt_info)'
