# shellcheck disable=SC2148

{%@@ if ssh_agent @@%}
export SSH_AUTH_SOCK="{{@@ ssh_agent @@}}"
{%@@ else @@%}
alias ops='eval $(op signin)'

# op-ssh-add loads an SSH private key from 1Password into a running ssh-agent.
# By default, it loads the `host_ssh_key_name` key from the dotdrop config.
function op-ssh-add() {
  if ! op whoami >/dev/null; then
    ops
  fi

  local key="${1:-{{@@ host_ssh_key_name @@}}}"
  op read "op://Private/${key}/private_key?ssh-format=openssh" | ssh-add -
}
{%@@ endif @@%}

# op-check-vault looks for any logins which match a given username in the
# specified vault, while ignoring any with the 'WrongVaultOk' tag
function op-check-vault() {
  local vault
  local username

  [ $# -ge 1 ] || return 1

  vault=$1
  username=${2:-adamjennybrown}

  op item list --categories Login --vault "$vault" --format json |
    op item get - --format json |
      jq "select(
             ((.fields.[] | select(.id == \"username\") | .value == null) or
              (.fields.[] | select(.id == \"username\") | .value | contains(\"$username\"))) and
             (.tags | contains([\"WrongVaultOk\"]) | not)) | .id"
}
