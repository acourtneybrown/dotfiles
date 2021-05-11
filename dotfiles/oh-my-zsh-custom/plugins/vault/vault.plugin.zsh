# Install useful functions for vault at Confluent

if [[ $commands[vault] ]]; then

  # vault_login handles the perfered login approach for Confluent
  function vault_login() {
    vault login -method=oidc -path=okta
  }

  # vault_switch changes the VAULT_ADDR to one of the Cire-managed hosts
  function vault_switch() {
    local hosts=(vault vaultnonprod vaultunstable)

    if [[ ${#} < 1 || ! $hosts[(i)${1}] -le ${#hosts} ]]; then
      echo "usage: vault_switch <vault | vaultnonprod | vaultunstable>"
      return
    fi
    export VAULT_ADDR="https://${1}.cireops.gcp.internal.confluent.cloud"
  }

  # vault_jenkins_secret matches the tooling used in jenkins-common
  function vault_jenkins_secret() {
    local SECRET="${1}"
    local KEY="${2}"

    vault kv get -field "${KEY}" v1/ci/kv/"${SECRET}"
  }

  vault_switch vault
fi
