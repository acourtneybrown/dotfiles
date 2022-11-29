# shellcheck disable=SC2148

# shellcheck disable=SC2157
if [[ -n "{{@@ ssh_agent @@}}" ]]; then
  export SSH_AUTH_SOCK="{{@@ ssh_agent @@}}"
fi
