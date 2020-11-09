path+=(/usr/local/opt/helm@2/bin)

typeset -U path
export PATH

if [[ $commands[helm] ]]; then
  helm init --upgrade > /dev/null

  if [[ -z $(helm repo list | grep helm-cloud) ]]; then
    # Run in subshell to ensure that info from ~/.secrets cleared
    (
      source ~/.secrets

      helm repo add helm-cloud \
        https://confluent.jfrog.io/confluent/helm-cloud \
        --username ${artifactory_user} \
        --password ${artifactory_password}
    )
  fi
fi
