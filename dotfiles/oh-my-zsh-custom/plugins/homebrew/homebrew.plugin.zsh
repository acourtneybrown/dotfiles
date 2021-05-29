[ -d "/usr/local/Homebrew" ] && eval "$("/usr/local/Homebrew/bin/brew" shellenv)"
[ -d "/opt/homebrew" ] && eval "$("/opt/homebrew/bin/brew" shellenv)"

typeset -U path
export PATH
