# Run in subshell to ensure that info from ~/.secrets cleared
(
  source ~/.secrets

  function ensure_docker() {
    local host
    host="$1"
    mkdir -p ~/.docker
    touch ~/.docker/config.json
    if ! jq -e ".auths.\"${host}\"" ~/.docker/config.json > /dev/null; then
      docker login \
        "${host}" \
        --username ${artifactory_user} \
        --password ${artifactory_password}
    fi
  }

  ensure_docker "confluent-docker.jfrog.io"
  ensure_docker "confluent-docker-internal-dev.jfrog.io"
)
