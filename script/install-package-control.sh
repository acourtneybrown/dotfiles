#!/usr/bin/env bash

cd "$(dirname "$0")/.."
. script/functions

if [[ $# != 1 ]]; then
  abort "Must specify root directory for SublimeText configuration"
fi

config_root="$1"

if [ ! -f "${config_root}/Installed Packages/Package Control.sublime-package" ]; then
  mkdir -p "${config_root}/Installed Packages/"
  download_and_verify https://packagecontrol.io/Package%20Control.sublime-package \
    6f4c264a24d933ce70df5dedcf1dcaeeebe013ee18cced0ef93d5f746d80ef60 \
    "${config_root}/Installed Packages/Package Control.sublime-package"
fi
