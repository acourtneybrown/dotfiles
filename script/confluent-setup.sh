#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

ensure_brewfile_installed Brewfile.confluent

pyenv install --skip-existing "$(pyenv latest --known 3.8)"
pyenv shell "$(pyenv latest 3.8)"
pipx install --python "$(command -v python)" confluent-release-tools

pyenv install --skip-existing "$(pyenv latest --known 3.9)"
pyenv shell "$(pyenv latest 3.9)"
pipx install --python "$(command -v python)" confluent-ci-tools

pyenv install --skip-existing "$(pyenv latest --known 3.11)"
pyenv shell "$(pyenv latest 3.11)"
pipx install ansible-hostmanager
pipx install bump2version
pipx install gimme-aws-creds
pipx install gql
pipx install tox
