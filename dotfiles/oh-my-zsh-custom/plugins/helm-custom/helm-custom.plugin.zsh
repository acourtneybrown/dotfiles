# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[helm]} ]]; then
  if ! helm repo list | grep -q helm-cloud; then
    # Run in subshell to ensure that secrets aren't retained
    (
      artifactory_user=$(op item get "JFrog Artifactory" --format json | jq '.urls[0].href')
      artifactory_password=$(op item get "JFrog Artifactory" --fields "API Key")

      # shellcheck disable=SC2154
      helm repo add helm-cloud \
        https://confluent.jfrog.io/confluent/helm-cloud \
        --username "${artifactory_user}" \
        --password "${artifactory_password}"
    )
  fi
fi
