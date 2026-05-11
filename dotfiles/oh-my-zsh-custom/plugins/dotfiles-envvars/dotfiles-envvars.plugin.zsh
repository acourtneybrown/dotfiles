# shellcheck shell=bash

export DOTFILES_SKIP_CONFIRMATION=y
export DOTFILES_SKIP_LOGIN_WINDOW=y
if [[ $(whoami) != virtualbuddy ]]; then
  export HOMEBREW_PROCESS_MAS=y
fi
