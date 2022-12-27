# shellcheck disable=SC2148

if [[ -d "${HOME}/.rbenv/bin" ]]; then
  # Actually *want* path to be split
  # shellcheck disable=2206
  path=("${HOME}/.rbenv/bin" $path)
  _evalcache rbenv init - zsh
fi

[[ -d "${HOME}/.linuxbrew" ]] && _evalcache "${HOME}/.linuxbrew/bin/brew" shellenv
[[ -d /home/linuxbrew/.linuxbrew ]] && _evalcache /home/linuxbrew/.linuxbrew/bin/brew shellenv

# shellcheck disable=SC2034
typeset -U path
export PATH
