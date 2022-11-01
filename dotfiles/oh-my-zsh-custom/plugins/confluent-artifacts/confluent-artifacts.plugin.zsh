# shellcheck disable=SC2148

# Run in subshell to ensure that info from ${HOME}/.secrets cleared
(
  # shellcheck disable=SC1090,SC1091
  source "${HOME}/.secrets"

  function ensure_docker() {
    local host
    host="${1}"
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

alias ecr_login="gimme-aws-creds --profile devprod-prod && aws ecr get-login-password --region us-west-2 --profile devprod-prod | docker login --username AWS --password-stdin 519856050701.dkr.ecr.us-west-2.amazonaws.com"
alias pip-login='aws codeartifact login --profile devprod-prod --tool pip --domain confluent --domain-owner 519856050701 --region us-west-2 --repository pypi'
alias twine-login='aws codeartifact login --profile devprod-prod --tool twine --domain confluent --domain-owner 519856050701 --region us-west-2 --repository pypi-internal'

if ! gcloud components list --only-local-state 2>/dev/null | grep -q gke-gcloud-auth-plugin; then
  gcloud components install gke-gcloud-auth-plugin
else
  gcloud components update
fi
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
