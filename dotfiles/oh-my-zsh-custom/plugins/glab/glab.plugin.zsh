# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[glab]} ]]; then
  # _glclall is an internal function that clones all of the non-archived, projects for a given user/group
  function _glclall() {
    if [[ "${#}" -ne 1 ]]; then
      return 1
    fi

    glab api "${1}" --paginate | jq '.[] | select(.archived == false) | .path_with_namespace' | xargs -n 1 -I % -P 6 -t glab project clone %
  }

  # glclorg clones all of the non-archived projects under a GitLab group
  function glclgroup() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: glclgroup <group>"
      return
    fi
    _glclall "groups/${1}/projects"
  }

  # glclorg clones all of the non-archived projects under a GitLab user
  function glcluser() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: glcluser <user>"
      return
    fi
    _glclall "users/${1}/projects"
  }
fi
