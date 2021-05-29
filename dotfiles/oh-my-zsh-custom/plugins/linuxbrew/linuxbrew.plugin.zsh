# From https://docs.brew.sh/Homebrew-on-Linux#install
test -d "${HOME}/.linuxbrew" && eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

typeset -U path
export PATH
