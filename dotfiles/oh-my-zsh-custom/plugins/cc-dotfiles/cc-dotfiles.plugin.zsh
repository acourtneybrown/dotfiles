if [[ -d ~/.cc-dotfiles ]]; then
  source ~/.cc-dotfiles/caas.sh

  function cc-dotfiles_update() {
    git -C ~/.cc-dotfiles pull origin
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
