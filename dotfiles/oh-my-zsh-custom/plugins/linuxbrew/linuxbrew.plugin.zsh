export PATH="${HOME}/.rbenv/bin:${PATH}"
eval "$(rbenv init - zsh)"

[ -d "${HOME}/.linuxbrew" ] && eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
[ -d /home/linuxbrew/.linuxbrew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# shellcheck disable=SC2034
typeset -U path
export PATH
