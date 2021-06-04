# shellcheck disable=SC2148

# Include zsh-completions from homebrew if they are installed
if which brew &>/dev/null && [ -d "$(brew --prefix)/share/zsh-completions" ]; then
  # shellcheck disable=SC2206
  fpath=("$(brew --prefix)/share/zsh-completions" ${fpath})
fi
