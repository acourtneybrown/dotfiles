# Include dotdrop zsh completion configuration

# Dotfile management
export DOTDROP_AUTOUPDATE=no
alias dotdrop='eval $(grep -v "^#" ${HOME}/.secrets) {{@@ _dotdrop_dotpath @@}}/../dotdrop.sh'
