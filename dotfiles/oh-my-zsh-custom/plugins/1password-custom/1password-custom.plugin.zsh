# shellcheck disable=SC2148

{%@@ if ssh_agent @@%}
export SSH_AUTH_SOCK="{{@@ ssh_agent @@}}"
{%@@ else @@%}
alias ops='eval $(op signin)'

# op-ssh-add loads an SSH private key from 1Password into a running ssh-agent.
# By default, it loads the `host_ssh_key_name` key from the dotdrop config.
function op-ssh-add() {
  local key="${1:-{{@@ host_ssh_key_name @@}}}"
  op read "op://Private/${key}/private_key?ssh-format=openssh" | ssh-add -
}
{%@@ endif @@%}
