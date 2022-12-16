# shellcheck disable=SC2148

autoload -U colors && colors

function modern-unix::message() {
  # shellcheck disable=SC2154
  echo "${fg[red]}${bg[white]}Use ${1} - ${fg[blue]}${2}${reset_color}" >&2
}

function ls() {
  local args=(exa https://github.com/ogham/exa)
  modern-unix::message "${args[@]}"
  /bin/ls "${@}"
  modern-unix::message "${args[@]}"
}

function cat() {
  local args=(bat https://github.com/sharkdp/bat)
  modern-unix::message "${args[@]}"
  /bin/cat "${@}"
  modern-unix::message "${args[@]}"
}

function less() {
  local args=(bat https://github.com/sharkdp/bat)
  modern-unix::message "${args[@]}"
  /usr/bin/less "${@}"
  modern-unix::message "${args[@]}"
}

function diff() {
  local args=(delta https://github.com/dandavison/delta)
  modern-unix::message "${args[@]}"
  /usr/bin/diff "${@}"
  modern-unix::message "${args[@]}"
}

function find() {
  local args=(fd https://github.com/sharkdp/fd)
  modern-unix::message "${args[@]}"
  /usr/bin/find "${@}"
  modern-unix::message "${args[@]}"
}

function grep() {
  local args=(rg https://github.com/BurntSushi/ripgrep)
  modern-unix::message "${args[@]}"
  /usr/bin/grep "${@}"
  modern-unix::message "${args[@]}"
}
