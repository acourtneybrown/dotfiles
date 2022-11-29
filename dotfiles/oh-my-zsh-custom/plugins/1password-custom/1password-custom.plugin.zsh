# shellcheck disable=SC2148

{%@@ if ssh_agent @@%}
export SSH_AUTH_SOCK="{{@@ ssh_agent @@}}"
{%@@ endif @@%}
