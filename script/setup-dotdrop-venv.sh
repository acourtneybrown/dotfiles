#!/usr/bin/env bash

set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

if [ ! -d env ]; then
  ensure_command "python3"
  python3 -m venv env
  # shellcheck disable=1091
  source env/bin/activate
  pip install -r dotdrop/requirements.txt
  deactivate
fi
