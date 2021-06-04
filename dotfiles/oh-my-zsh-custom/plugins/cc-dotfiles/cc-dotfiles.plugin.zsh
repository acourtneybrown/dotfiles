# shellcheck disable=SC2148

if [[ -d "${HOME}/.cc-dotfiles" ]]; then
  # Ensure that the auto-update behavior is only run by one shell at a time
  flock "${HOME}/.cc-dotfiles" bash -c "source \${HOME}/.cc-dotfiles/caas.sh"

  # shellcheck disable=SC1091
  source "${HOME}/.cc-dotfiles/caas.sh"

  function cc-dotfiles_update() {
    git -C "${HOME}/.cc-dotfiles" pull origin
  }

  function cc-dotfiles_alpha() {
    export CC_DOTFILES_ALPHA=true
  }

  function cc-dotfiles_beta() {
    export CC_DOTFILES_BETA=true
  }

  function cc-dotfiles_ga() {
    unset CC_DOTFILES_ALPHA
    unset CC_DOTFILES_BETA
  }

  export OKTA_DEVICE_ID=uft62yn7znTudH1Nr357
fi
