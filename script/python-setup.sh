#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")/.."

pyenv install --skip-existing "$(pyenv latest --known 3.11)"
pyenv shell "$(pyenv latest 3.11)"
pipx install python-kasa
pipx install python-vipaccess
