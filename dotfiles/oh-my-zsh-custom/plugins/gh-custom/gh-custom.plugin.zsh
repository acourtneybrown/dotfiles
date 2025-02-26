# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[gh]} ]]; then
  # shellcheck disable=SC2296
  LOCAL_GH="$(dirname "${(%):-%N}")/gh"

  # _ghclall is an internal function that clones all of the non-archived, repos for a given user/org
  function _ghclall() {
    if [[ "${#}" -ne 1 ]]; then
      return 1
    fi

    $LOCAL_GH api "${1}" --paginate --jq '.[] | select(.archived == false) | .full_name' | xargs -n 1 -I % -P 6 -t "$LOCAL_GH" repo clone %
  }

  # ghclorg clones all of the non-archived repos under a GitHub org
  function ghclorg() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: ghclorg <org>"
      return
    fi
    _ghclall "orgs/${1}/repos"
  }

  # ghcluser clones all of the non-archived repos under a GitHub user
  function ghcluser() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: ghcluser <user>"
      return
    fi

    if [[ ${1} == $(git config github.user) ]]; then
      _ghclall "user/repos?type=owner"
    else
      _ghclall "users/${1}/repos"
    fi
  }

  # ghrmarchived deletes the local clone for any repo that has been archived on GitHub
  function ghrmarchived() {
    local archived
    for DIR in *; do
      if [[ -d "${DIR}/.git" ]]; then
        archived=$(
          cd "$DIR" || return
          $LOCAL_GH api "repos/{owner}/{repo}" --jq '.archived'
        )
        $archived && {
          echo "removing archived repo '$DIR'"
          rm -rf -- "$DIR"
        }
      fi
    done
  }

  # ghrmdeleted deletes the local clone for any repo that has been deleted on GitHub
  function ghrmdeleted() {
    for DIR in *; do
      if [[ -d "${DIR}/.git" ]]; then
        if ! (cd "$DIR" && gh api --silent "repos/{owner}/{repo}" 2>/dev/null); then
          echo "removing deleted repo '$DIR'"
          rm -rf -- "$DIR"
        fi
      fi
    done
  }

  alias ghrmremoved='ghrmdeleted; ghrmarchived'
fi
