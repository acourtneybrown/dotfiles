#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
source script/functions

pyenv install --skip-existing "$(pyenv latest --known 3.11)"
version=$(pyenv latest 3.11)
pipx_install "${version}" python-kasa python-vipaccess
