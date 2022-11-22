# shellcheck disable=SC2148

# Include dotdrop zsh completion configuration
fpath+=$(pwd)

function dotdrop() {
  # "{{@@ _dotdrop_dotpath @@}}/../dotdrop.sh" "${@}"
  dotdrop.sh --cfg "{{@@ _dotdrop_dotpath @@}}/config.yaml"
}
