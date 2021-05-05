#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."
. script/functions

if [ ! -d env ]; then
  if command -v python3; then
    python3 -m venv env
    # shellcheck disable=1091
    source env/bin/activate
    pip install -r dotdrop/requirements.txt
    deactivate
  else
    abort "Python3 must be installed"
  fi
fi
