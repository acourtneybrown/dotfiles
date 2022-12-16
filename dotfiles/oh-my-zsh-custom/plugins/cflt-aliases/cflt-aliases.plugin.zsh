# shellcheck disable=SC2148

alias ct="cd ~/confluent/temp"
function ctcl() {
  cd ~/confluent/temp || return
  gcl "ghc:${1}"

  # shellcheck disable=SC2164
  cd "${1}"
}
