export GOENV_ROOT="$HOME/.goenv"

function goenv_update() {
  git -C "${GOENV_ROOT}" pull origin
}

path=("${GOENV_ROOT}/bin/" $path)
eval "$(goenv init -)"
path=("${GOROOT}/bin" $path)
path+=("${GOPATH}/bin")

typeset -U path
export PATH
