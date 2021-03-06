# shellcheck disable=SC2148

GOENV_ROOT="${HOME}/.goenv"

if [[ -d ${GOENV_ROOT} ]]; then
  export GOENV_ROOT

  function goenv_update() {
    git -C "${GOENV_ROOT}" pull origin
  }

  # shellcheck disable=SC2206
  path=("${GOENV_ROOT}/bin/" $path)
  eval "$(goenv init -)"

  # shellcheck disable=SC2206
  # shellcheck disable=SC2128
  path=("${GOROOT}/bin" $path)

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
