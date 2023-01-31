# shellcheck disable=SC2148

alias ct='cd ${HOME}/confluent/temp'
function ctcl() {
  if [[ ${#} -lt 1 ]]; then
    echo "missing repo to clone"
    return
  fi

  ct || return
  gcl "ghc:${1}"

  # shellcheck disable=SC2164
  cd "${1}"
}
