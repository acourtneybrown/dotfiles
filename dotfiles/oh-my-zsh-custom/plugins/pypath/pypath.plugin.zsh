# pypath adds the given Homebrew Python version to the end of PATH
function pypath() {
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
