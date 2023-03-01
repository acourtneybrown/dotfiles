# shellcheck shell=bash

function docker::ensure_login() {
  local host="${1}"
  local user="${2}"
  local password="${3}"
  mkdir -p "${HOME}/.docker"
  touch "${HOME}/.docker/config.json"
  if ! jq -e ".auths.\"${host}\"" "${HOME}/.docker/config.json" >/dev/null; then
    # shellcheck disable=SC2154
    docker login \
      "${host}" \
      --username "${user}" \
      --password "${password}"
  fi
}
