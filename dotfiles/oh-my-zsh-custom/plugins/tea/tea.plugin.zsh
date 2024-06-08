# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[tea]} ]]; then
  # _gtclall is an internal function that clones all of the non-archived repos for a given user/org
  function _gtclall() {
    local auth_token
    if [[ "${#}" -ne 2 ]]; then
      return 1
    fi
    auth_token=$(yq ".logins[] | select(.name == \"${1}\") | .token" "{{@@ xdg_config_home @@}}/tea/config.yml")

    curl -fsSL -X 'GET' "https://${1}/api/v1/${2}" -H 'accept: application/json' -H "Authorization: token ${auth_token}" |
      jq '.[] | select(.archived == false) | .ssh_url' | xargs -n 1 -I % -P 6 -t git clone %
  }

  # gtclorg clones all of the non-archived projects under a Gitea org
  function gtclorg() {
    local gitea_host
    if [[ "${#}" -lt 1 ]]; then
      echo "Usage: glclgroup <group> [gitea_host]"
      return
    fi
    gitea_host="${2:-{{@@ gitea_hostname @@}}}"
    _gtclall "${gitea_host}" "orgs/${1}/repos"
  }

  # glclorg clones all of the non-archived projects under a Gitea user
  function gtcluser() {
    local gitea_host
    if [[ "${#}" -lt 1 ]]; then
      echo "Usage: glcluser <user> [gitea_host]"
      return
    fi
    gitea_host="${2:-{{@@ gitea_hostname @@}}}"
    _gtclall "${gitea_host}" "users/${1}/repos"
  }
fi
