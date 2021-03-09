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

  vault_switch vault
fi
