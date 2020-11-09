# Include dotdrop zsh completion configuration

# Dotfile management
export DOTDROP_AUTOUPDATE=no
alias dotdrop='eval $(grep -v "^#" ${HOME}/.secrets) {{@@ _dotdrop_dotpath @@}}/../dotdrop.sh'

# dotdrop_upgrade updates the dotdrop submodule to the specified tag if given,
# otherwise the latest tagged release
function dotdrop_upgrade() {
  local tag
  cd "{{@@ _dotdrop_dotpath @@}}"/../dotdrop
  git fetch --tags
  if [[ $# -lt 1 ]]; then
    tag=$(git tag --sort=-v:refname -l "${1}*" | head -1)
  else
    tag="$1"
  fi
  git checkout "${tag}"
}
