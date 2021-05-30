# shellcheck disable=SC2148

# Run in subshell to ensure that info from ${HOME}/.secrets cleared
(
  source "${HOME}/.secrets"

  function ensure_docker() {
    local host
    host="$1"
    mkdir -p "${HOME}/.docker"
    touch "${HOME}/.docker/config.json"
    if ! jq -e ".auths.\"${host}\"" "${HOME}/.docker/config.json" >/dev/null; then
      # shellcheck disable=SC2154
      docker login \
        "${host}" \
        --username "${artifactory_user}" \
        --password "${artifactory_password}"
    fi
  }

  ensure_docker "confluent-docker.jfrog.io"
  ensure_docker "confluent-docker-internal-dev.jfrog.io"
)
