# shellcheck disable=SC2148

# Install useful functions for vault at Confluent

if [[ ${commands[vault]} ]]; then

  # vault_login handles the prefered login approach for Confluent
  function vault_login() {
    vault login -method=oidc -path=okta -no-print &>/dev/null
  }

  # vault_switch changes the VAULT_ADDR to one of the Cire-managed hosts
  function vault_switch() {
    case "${1}" in
    vault | vaultnonprod | vaultunstable)
      export VAULT_ADDR="https://${1}.cireops.gcp.internal.confluent.cloud"
      ;;
    *)
      echo "usage: vault_switch <vault | vaultnonprod | vaultunstable>"
      ;;
    esac
  }

  # vault_jenkins_secret matches the tooling used in jenkins-common
  function vault_jenkins_secret() {
    # remove optional trailing comma (,)
    local SECRET="${1/%,/}"
    local KEY="${2/%,/}"

    vault kv get -field "${KEY}" v1/ci/kv/"${SECRET}"
  }

  alias vault-login=vault_login
  alias vault-switch=vault_switch
  alias vault-jenkins-secret=vault_jenkins_secret

  vault_switch vault
fi
