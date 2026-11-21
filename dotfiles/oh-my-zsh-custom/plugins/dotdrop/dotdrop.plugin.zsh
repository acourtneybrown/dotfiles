# shellcheck disable=SC2148

# Include dotdrop zsh completion configuration
fpath+=$(pwd)
export DOTDROP_CONFIG="{{@@ _dotdrop_dotpath @@}}/../config.yaml"
export DOTDROP_MIME_TEXT=text/plain,application/x-wine-extension-ini
{%@@ if mac @@%}
export DOTDROP_WORKERS=$(( $(sysctl -n hw.ncpu) * 3 / 4 ))
{%@@ elif linux or synology_dsm @@%}
export DOTDROP_WORKERS=$(( $(nproc) * 3 / 4 ))
{%@@ endif @@%}
