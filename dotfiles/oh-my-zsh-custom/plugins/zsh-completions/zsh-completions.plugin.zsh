# shellcheck disable=SC2148

# Include zsh-completions from homebrew if they are installed
if command -v brew &>/dev/null && [[ -d "$(brew --prefix)/share/zsh-completions" ]]; then
  # shellcheck disable=SC2206
  fpath=("$(brew --prefix)/share/zsh-completions" "$(brew --prefix)/share/zsh/site-functions" ${fpath})

  autoload -Uz compinit
  {%@@ if synology_dsm @@%}
  compinit -u
  {%@@ else @@%}
  compinit
  {%@@ endif @@%}
fi
