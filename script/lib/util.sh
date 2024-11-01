# shellcheck shell=bash

function util::escape() {
  printf '%s' "${1//\'/\'}"
}

function util::abort() {
  echo "!!! ${*}" >&2
  exit 1
}

function util::is_mac() {
  [[ "$(uname -s)" = "Darwin" ]]
}

function util::is_arm() {
  [[ "$(uname -m)" = "arm64" ]]
}

function util::is_linux() {
  [[ "$(uname -s)" = "Linux" ]]
}

function util::sudo_keepalive() {
  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until current script has finished
  while true; do
    sudo -n true
    sleep 60
    kill -0 "${$}" || exit
  done 2>/dev/null &
}

function util::sudo_check_then_alive() {
  # We want to always prompt for sudo password at least once rather than doing
  # root stuff unexpectedly.
  sudo --reset-timestamp

  util::sudo_keepalive
}

function util::check_sha256() {
  if util::is_mac; then
    shasum -a 256 "${@}"
  else
    sha256sum "${@}"
  fi
}

function util::download_and_verify() {
  local url
  local sha256
  local output
  local tempfile

  url="${1}"
  sha256="${2}"
  output="${3}"
  tempfile=$(mktemp /tmp/sha256.XXXXXX)
  echo "${sha256}  $(basename "${output}")" >"${tempfile}"

  (
    cd "$(dirname "${output}")" || exit
    curl -fLsS --output "${output}" "${url}"
    if ! util::check_sha256 -c "${tempfile}" >/dev/null 2>&1; then
      echo "Hash did not match"
    else
      echo "ok"
    fi
  )

  rm -f "${tempfile}"
}
