# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[glab]} ]]; then
  # shellcheck disable=SC2296
  LOCAL_GLAB="$(dirname "${(%):-%N}")/glab"

  # _glclall is an internal function that clones all of the non-archived, projects for a given user/group
  function _glclall() {
    if [[ "${#}" -ne 1 ]]; then
      return 1
    fi

    "$LOCAL_GLAB" api "${1}" --paginate | jq '.[] | select(.archived == false) | .path_with_namespace' | xargs -n 1 -I % -P 6 "$LOCAL_GLAB" project clone %
  }

  # glclgroup clones all of the non-archived projects under a GitLab group
  function glclgroup() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: glclgroup <group>"
      return
    fi
    _glclall "groups/${1}/projects"
  }

  # glcluser clones all of the non-archived projects under a GitLab user
  function glcluser() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: glcluser <user>"
      return
    fi
    _glclall "users/${1}/projects"
  }
fi
