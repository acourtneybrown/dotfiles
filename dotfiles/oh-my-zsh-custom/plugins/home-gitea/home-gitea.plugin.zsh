# shellcheck disable=SC2148

# shellcheck disable=SC1091
source "{{@@ _dotdrop_dotpath @@}}/../script/lib/docker.sh"

gitea_username_cb="op item get 'Gitea (acourtneybrown)' --field username"
gitea_container_token_cb="op item get 'Gitea (acourtneybrown)' --field 'Container token'"
docker::ensure_login gitea.notcharlie.com "${gitea_username_cb}" "${gitea_container_token_cb}"
unset gitea_container_token_cb
