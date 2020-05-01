# Include dotdrop zsh completion configuration

# Dotfile management
alias dotdrop='eval $(grep -v "^#" {{@@ _dotdrop_dotpath @@}}/../.env) {{@@ _dotdrop_dotpath @@}}/../dotdrop.sh'
