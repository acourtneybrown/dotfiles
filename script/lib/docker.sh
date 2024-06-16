# shellcheck shell=bash

# docker::ensure_login takes the host, a command to evaluate for the username, and
# a command to evaluate for the password.  if the host does not have login info
# in ~/.docker/config.json, it will be added via `docker login`
function docker::ensure_login() {
  local host="${1}"
  if [[ ! -f "${HOME}/.docker/config.json" ]] ||
    ! jq -e ".auths.\"${host}\"" "${HOME}/.docker/config.json" >/dev/null; then
    local user
    local password
    user=$(eval "${2}")
    password=$(eval "${3}")
    docker login \
      "${host}" \
      --username "${user}" \
      --password "${password}" || echo "Failed to log in to Docker repo: ${host}"
  fi
}
