# shellcheck disable=SC2148

if [ -d /usr/local/opt/helm@2/bin ]; then
  path+=(/usr/local/opt/helm@2/bin)

  typeset -U path
  export PATH
fi

if [[ ${commands[helm]} ]]; then
  if helm init --upgrade >/dev/null 2>&1; then
    if helm repo list | ! grep -q helm-cloud; then
      # Run in subshell to ensure that info from ${HOME}/.secrets cleared
      (
        # shellcheck disable=SC1090,SC1091
        source "${HOME}/.secrets"

        # shellcheck disable=SC2154
        helm repo add helm-cloud \
          https://confluent.jfrog.io/confluent/helm-cloud \
          --username "${artifactory_user}" \
          --password "${artifactory_password}"
      )
    fi
  else
    echo "Docker not currently running"
  fi
fi
