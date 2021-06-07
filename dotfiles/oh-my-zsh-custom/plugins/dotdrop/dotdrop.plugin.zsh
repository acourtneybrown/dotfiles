# shellcheck disable=SC2148

# Dotfile management
export DOTDROP_AUTOUPDATE=no

# dotdrop_versions lists the available tags/releases of the dotdrop submodule
function dotdrop_versions() {
  local dotdrop_location
  dotdrop_location="{{@@ _dotdrop_dotpath @@}}"/../dotdrop
  git -C "${dotdrop_location}" fetch --tags
  git -C "${dotdrop_location}" tag --sort=-v:refname -l "${1}*"
}

# dotdrop_upgrade updates the dotdrop submodule to the specified tag if given,
# otherwise the latest tagged release
function dotdrop_upgrade() {
  local tag
  local dotdrop_location
  dotdrop_location="{{@@ _dotdrop_dotpath @@}}"/../dotdrop
  git -C "${dotdrop_location}" fetch --tags
  if [[ ${#} -lt 1 ]]; then
    # only pick up the "v"-beginning version tags
    tag=$(dotdrop_versions "v" | head -1)
  else
    tag="${1}"
  fi
  git -C "${dotdrop_location}" checkout "${tag}"
}

# Include dotdrop zsh completion configuration
fpath+=$(pwd)

function dotdrop() {
  # Need the contents of ~/.secrets to be split for all variables
  # shellcheck disable=2046
  eval $(grep -v "^#" "${HOME}/.secrets") "{{@@ _dotdrop_dotpath @@}}/../dotdrop.sh" "${@}"
}
