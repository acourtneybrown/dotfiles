# shellcheck disable=SC2148

# Include dotdrop zsh completion configuration
fpath+=$(pwd)

function dotdrop() {
  /usr/local/bin/dotdrop --cfg "{{@@ _dotdrop_dotpath @@}}/../config.yaml" "${@}"
}
