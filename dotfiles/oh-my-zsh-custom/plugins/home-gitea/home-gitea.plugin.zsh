# shellcheck disable=SC2148

# shellcheck disable=SC1091
source "{{@@ _dotdrop_dotpath @@}}/../script/lib/docker.sh"

docker::ensure_login gitea.notcharlie.com "{{@@ gitea_username @@}}" "{{@@ gitea_container_token @@}}"
