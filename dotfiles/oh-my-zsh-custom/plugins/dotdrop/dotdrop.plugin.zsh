# shellcheck disable=SC2148

# Include dotdrop zsh completion configuration
fpath+=$(pwd)

function dotdrop() {
  "$(brew --prefix)/bin/dotdrop" --cfg "{{@@ _dotdrop_dotpath @@}}/../config.yaml" "${@}"
}
