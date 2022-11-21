#!/usr/bin/env bash

# Adapted from https://github.com/MikeMcQuaid/strap

set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

# Install the Xcode Command Line Tools.
if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
  echo "Installing the Xcode Command Line Tools:"
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch "${CLT_PLACEHOLDER}"

  # shellcheck disable=SC2086,SC2183
  printf -v MACOS_VERSION_NUMERIC "%02d%02d%02d" ${MACOS_VERSION//./ }
  if [ "${MACOS_VERSION_NUMERIC}" -ge "100900" ] &&
    [ "${MACOS_VERSION_NUMERIC}" -lt "101000" ]; then
    CLT_MACOS_VERSION="Mavericks"
  else
    CLT_MACOS_VERSION="$(echo "${MACOS_VERSION}" | grep -E -o "10\\.\\d+")"
  fi
  if [ "${MACOS_VERSION_NUMERIC}" -ge "101300" ]; then
    CLT_SORT="sort -V"
  else
    CLT_SORT="sort"
  fi

  CLT_PACKAGE=$(softwareupdate -l |
    grep -B 1 -E "Command Line (Developer|Tools)" |
    awk -F"*" '/^ +\*/ {print $2}' |
    sed 's/^ *//' |
    grep "${CLT_MACOS_VERSION}" |
    ${CLT_SORT} |
    tail -n1)
  sudo softwareupdate -i "${CLT_PACKAGE}"
  sudo rm -f "${CLT_PLACEHOLDER}"
  if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
    if [ -n "${STRAP_INTERACTIVE}" ]; then
      echo "Requesting user install of Xcode Command Line Tools:"
      xcode-select --install
    else
      echo
      abort "Run 'xcode-select --install' to install the Xcode Command Line Tools."
    fi
  fi
fi

xcode_license
