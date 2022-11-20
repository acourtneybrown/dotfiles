# shellcheck disable=SC2148

function artifactory_user() {
  op item get "JFrog Artifactory" --format json | jq -r '.urls[0].href'
}

function artifactory_password() {
  op item get "JFrog Artifactory" --fields "API Key"
}

function ensure_docker() {
  local host

  host="${1}"
  mkdir -p "${HOME}/.docker"
  touch "${HOME}/.docker/config.json"
  if ! jq -e ".auths.\"${host}\"" "${HOME}/.docker/config.json" >/dev/null; then

    # shellcheck disable=SC2154
    docker login \
      "${host}" \
      --username "$(artifactory_user)" \
      --password "$(artifactory_password)"
  fi
}

ensure_docker "confluent-docker.jfrog.io"
ensure_docker "confluent-docker-internal-dev.jfrog.io"

# shellcheck disable=SC2154
if [[ ${commands[helm]} ]]; then
  if ! helm repo list | grep -q helm-cloud; then
    # Run in subshell to ensure that secrets aren't retained
    (

      # shellcheck disable=SC2154
      helm repo add helm-cloud \
        https://confluent.jfrog.io/confluent/helm-cloud \
        --username "$(artifactory_user)" \
        --password "$(artifactory_password)"
    )
  fi
fi

alias ecr_login="gimme-aws-creds --profile devprod-prod && aws ecr get-login-password --region us-west-2 --profile devprod-prod | docker login --username AWS --password-stdin 519856050701.dkr.ecr.us-west-2.amazonaws.com"
alias pip_login='gimme-aws-creds --profile devprod-prod && aws codeartifact login --profile devprod-prod --tool pip --domain confluent --domain-owner 519856050701 --region us-west-2 --repository pypi'
alias twine_login='gimme-aws-creds --profile devprod-prod && aws codeartifact login --profile devprod-prod --tool twine --domain confluent --domain-owner 519856050701 --region us-west-2 --repository pypi-internal'
alias ecr-login=ecr_login
alias pip-login=pip_login
alias twine-login=twine_login

if command -v gcloud >/dev/null; then
  if ! gcloud components list --only-local-state 2>/dev/null | grep -q gke-gcloud-auth-plugin; then
    gcloud components install gke-gcloud-auth-plugin
  else
    gcloud components update
  fi
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
else
  echo "gcloud tool not installed"
fi
