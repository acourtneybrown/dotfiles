source ~/.secrets

function ensure_docker() {
  host="$1"
  mkdir -p ~/.docker
  touch ~/.docker/config.json
  if ! jq -e ".auths.\"${host}\"" ~/.docker/config.json; then
    docker login \
      "${host}" \
      --username ${artifactory_user} \
      --password ${artifactory_password}
  fi
}

ensure_docker "confluent-docker.jfrog.io"
ensure_docker "confluent-docker-internal-dev.jfrog.io"
