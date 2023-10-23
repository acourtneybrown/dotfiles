# shellcheck disable=SC2148

# Avoid prompting for update if launching from within IntelliJ
if [[ -n "${INTELLIJ_ENVIRONMENT_READER}" ]]; then
  return
fi

if [[ -d "${HOME}/.cc-dotfiles" ]]; then
  export CC_AUTO_UPDATE=false
  export BUILDBUDDY_PERSONAL_KEY="{{@@ buildbuddy_readwrite_key @@}}"

  # shellcheck disable=SC1091,SC1090
  source "${HOME}/.cc-dotfiles/caas.sh"
  bazel::use_cache

  function cc-dotfiles-alpha() {
    export CC_DOTFILES_ALPHA=true
    # shellcheck disable=SC1091,SC1090
    source "${HOME}/.cc-dotfiles/caas.sh"
  }

  function cc-dotfiles-beta() {
    export CC_DOTFILES_BETA=true
    # shellcheck disable=SC1091,SC1090
    source "${HOME}/.cc-dotfiles/caas.sh"
  }
fi
