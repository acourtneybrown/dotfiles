# Include dotdrop zsh completion configuration

# Dotfile management
alias dotdrop='eval $(grep -v "^#" ${HOME}/.secrets) {{@@ _dotdrop_dotpath @@}}/../dotdrop.sh'
