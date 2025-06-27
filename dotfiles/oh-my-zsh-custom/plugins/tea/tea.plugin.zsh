# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[tea]} ]]; then
  # shellcheck disable=SC1091
  PROG=tea _CLI_ZSH_AUTOCOMPLETE_HACK=1 source "{{@@ xdg_config_home @@}}/tea/autocomplete.zsh"

  # shellcheck disable=SC2296
  LOCAL_TEA="$(dirname "${(%):-%N}")/tea"

  # _gtclall is an internal function that clones all of the non-archived repos for a given user/org
  function _gtclall() {
    if [[ "${#}" -ne 1 ]]; then
      return 1
    fi

    "$LOCAL_TEA" repos list --limit 500 --output yaml | grep -v '^NOTE:' | yq ".[] | select(.owner == \"${1}\") | .ssh" | xargs -n 1 -I % "$LOCAL_TEA" clone %
  }

  # gtclorg clones all of the non-archived projects under a Gitea org
  function gtclorg() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: gtclorg <org>"
      return
    fi
    _gtclall "${1}"
  }

  # glclorg clones all of the non-archived projects under a Gitea user
  function gtcluser() {
    if [[ "${#}" -ne 1 ]]; then
      echo "Usage: gtcluser <user>"
      return
    fi
    _gtclall "${1}"
  }
fi
