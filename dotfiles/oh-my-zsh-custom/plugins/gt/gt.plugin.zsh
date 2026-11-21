# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[gt]} ]]; then
  # shellcheck disable=SC2296
  LOCAL_GT="$(dirname "${(%):-%N}")/gt"

  # _gtclall is an internal function that clones all of the non-archived repos for a given user/org
  function _gtclall() {
    if [[ "${#}" -ne 1 ]]; then
      return 1
    fi

    "$LOCAL_GT" api --paginate "$1" --jq '.[] | select(.archived == false) | .ssh_url' | xargs -n 1 -I % "$LOCAL_GT" repo clone %
  }

  # gtclorg clones all of the non-archived projects under a Gitea org
  function gtclorg() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: gtclorg <org>"
      return
    fi
    _gtclall "orgs/${1}/repos"
  }

  # glclorg clones all of the non-archived projects under a Gitea user
  function gtcluser() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: gtcluser <user>"
      return
    fi
    _gtclall "users/${1}/repos"
  }
fi
