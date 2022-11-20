# shellcheck disable=SC2148

export GOENV_ROOT="${HOME}/.goenv"

if [[ -d ${GOENV_ROOT} ]]; then
  export GOENV_ROOT

  # shellcheck disable=SC2206
  path=("${GOENV_ROOT}/bin/" $path)
  _evalcache goenv init -

  typeset -U path
  export PATH

  function goenv_prompt_info() {
    goenv version-name 2>/dev/null
  }

  # Want goenv_prompt_info evaluated later
  # shellcheck disable=SC2016
  RPROMPT+=' g$(goenv_prompt_info)'
else
  unset GOENV_ROOT
fi
