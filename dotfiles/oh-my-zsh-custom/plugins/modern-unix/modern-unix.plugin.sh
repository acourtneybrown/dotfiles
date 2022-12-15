# shellcheck disable=SC2148

autoload -U colors && colors

function modern-unix::message() {
  # shellcheck disable=SC2154
  echo "${fg[red]}${bg[white]}Use ${1}${reset_color}" >&2
}

function ls() {
  modern-unix::message exa
  /bin/ls "${@}"
  modern-unix::message exa
}

function cat() {
  modern-unix::message bat
  /bin/cat "${@}"
  modern-unix::message bat
}

function diff() {
  modern-unix::message delta
  /usr/bin/diff "${@}"
  modern-unix::message delta
}

function find() {
  modern-unix::message fd
  /usr/bin/find "${@}"
  modern-unix::message fd
}
