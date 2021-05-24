# pypath_last adds the given Homebrew Python version to the end of PATH
function pypath_last() {
  local version
  local bindir
  version="$1"
  bindir="/usr/local/opt/python@${version}/bin"
  if [[ -d ${bindir} ]]; then
    path+=("${bindir}")
  else
    echo "error: ${bindir} does not exist"
  fi

  typeset -U path
  export PATH
}

# pypath adds the given Homebrew Python version to the front of PATH
function pypath_first() {
  local version
  local bindir
  version="$1"
  bindir="/usr/local/opt/python@${version}/bin"
  if [[ -d ${bindir} ]]; then
    path=("${bindir}" ${path})
  else
    echo "error: ${bindir} does not exist"
  fi

  typeset -U path
  export PATH
}

alias pypath=pypath_first
