#!/usr/bin/env bash

set -e
cd "$(dirname "$(readlink -f "${0}")")"

# shellcheck disable=SC1091
. functions

if [[ ${#} != 1 ]]; then
  abort "Must specify root directory for SublimeText configuration"
fi

config_root="${1}"

if [ ! -f "${config_root}/Installed Packages/Package Control.sublime-package" ]; then
  mkdir -p "${config_root}/Installed Packages/"
  download_and_verify https://packagecontrol.io/Package%20Control.sublime-package \
    817937144c34c84c88cd43b85318b2656f9c3fac02f8f72cbc18360b2c26d139 \
    "${config_root}/Installed Packages/Package Control.sublime-package"
fi
