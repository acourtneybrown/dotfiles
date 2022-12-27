# shellcheck disable=SC2148

[[ -d "/usr/local/Homebrew" ]] && _evalcache /usr/local/Homebrew/bin/brew shellenv
[[ -d "/opt/homebrew" ]] && _evalcache /opt/homebrew/bin/brew shellenv

# shellcheck disable=SC2034
typeset -U path
export PATH
