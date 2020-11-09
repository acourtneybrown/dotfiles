GOENV_ROOT="${HOME}/.goenv"

if [[ -d ${GOENV_ROOT} ]]; then
  export GOENV_ROOT

  function goenv_update() {
    git -C "${GOENV_ROOT}" pull origin
  }

  path=("${GOENV_ROOT}/bin/" $path)
  eval "$(goenv init -)"
  path=("${GOROOT}/bin" $path)
  path+=("${GOPATH}/bin")

  typeset -U path
  export PATH

  function goenv_prompt_info() {
    goenv version-name 2> /dev/null
  }

  RPROMPT+=' g$(goenv_prompt_info)'
else
  unset GOENV_ROOT
fi
