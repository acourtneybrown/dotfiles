# shellcheck disable=SC2148

# Include dotdrop zsh completion configuration
fpath+=$(pwd)
export DOTDROP_CONFIG="{{@@ _dotdrop_dotpath @@}}/../config.yaml"
