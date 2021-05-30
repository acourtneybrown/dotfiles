# shellcheck disable=SC2148

[ -d "/usr/local/Homebrew" ] && eval "$("/usr/local/Homebrew/bin/brew" shellenv)"
[ -d "/opt/homebrew" ] && eval "$("/opt/homebrew/bin/brew" shellenv)"

# shellcheck disable=SC2034
typeset -U path
export PATH
